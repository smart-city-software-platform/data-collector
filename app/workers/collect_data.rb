require 'rest-client'
require 'net/http'
require 'json'

require_relative '../../lib/worker-manager/worker_supervisor.rb'

# The main goal of this class it is to make a request to resource and then
# parse the response. Afterwards store the new data on the database.
class CollectData
  include Sidekiq::Worker

  URI_COLLECT = '/collect'.freeze

  # Make collect of data from resource.
  # Our target: /basic_resources/:id/components/:id/
  def perform(uri, resource_id, collect_interval)
    supervisor = WorkerSupervisor.instance
    return if supervisor.resource_inactive? (resource_id)

    if supervisor.resource_updated? (resource_id)
      uri, collect_interval = update_resource(resource_id)
    end

    collected_json = request_json_from_resource_adaptor(uri) || return
    collected_json['data'].each do |capability_name, value|
      current_capability = Capability.find_by_name(capability_name)
      next if current_capability.nil?

      build = SensorValue.new
      build.value = value
      build.date = collected_json['updated_at']
      build.capability_id = current_capability.id
      build.platform_resource_id = resource_id
      # TODO: Use log class
      puts 'error' unless build.save
    end
    CollectData.perform_in(collect_interval.seconds,
                           uri, resource_id,
                           collect_interval)
  end

  private

  def request_json_from_resource_adaptor(uri)
    response = RestClient.get uri + URI_COLLECT
    validate_json(JSON.parse(response.body))
  end

  def validate_json(raw_json)
    return nil if raw_json['data'].nil? || raw_json['updated_at'].nil?
    DateTime.parse(raw_json['updated_at'])
    return nil unless raw_json['data'].is_a? Hash
    raw_json
  rescue
    return nil
  end

  def update_resource(resource_id)
    resource = PlatformResource.find(resource_id)
    uri = resource.uri
    collect_interval = resource.collect_interval
    return uri, collect_interval
  end
end
