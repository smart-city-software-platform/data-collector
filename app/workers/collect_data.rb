require 'net/http'
require 'json'

# The main goal of this class it is to make a request to resource and then
# parse the response. Afterwards store the new data on the database.
class CollectData
  include Sidekiq::Worker

  URI_COLLECT = '/collect'.freeze

  # Make collect of data from resource.
  # Our target: /basic_resources/:id/components/:id/
  def perform(uri, resource_id, collect_interval)
    begin
      parsed_uri = URI.parse(uri + URI_COLLECT)
    rescue URI::Error => ex
      puts 'Resource URI error: ' + ex
      return
    end

    request = Net::HTTP::Get.new(parsed_uri.to_s)
    response = Net::HTTP.start(parsed_uri.host, parsed_uri.port) do |http|
      http.request(request)
    end

    collected_json = JSON.parse(response.body)
    # TODO: Do not trust on the json, verify it before use it!
    collected_json['data'].each do |capability_name, value|
      current_capability = Capability.find_by_name(capability_name)
      next if current_capability.nil?

      build = SensorValue.new
      build.value = value
      build.date = collected_json['updated_at']
      build.capability_id = current_capability.id
      build.platform_resource_id = resource_id
      # TODO: Put it inside a begin/rescue
      unless build.save
        puts 'error'
      end
    end
    CollectData.perform_in(collect_interval.seconds,
                           uri, resource_id,
                           collect_interval)
  end
end
