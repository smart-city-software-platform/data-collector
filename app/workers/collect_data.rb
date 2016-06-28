require 'rest-client'

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
    return if supervisor.resource_inactive?(resource_id)

    if supervisor.resource_updated?(resource_id)
      uri, collect_interval = update_resource(resource_id)
    end

    collected_json = request_json_from_resource_adaptor(uri) || return
    collected_json['data'].each do |capability_name, value|
      capability_id = get_capability_id(capability_name)
      next if capability_id.nil?
      new_sensor_value(value, collected_json, capability_id, resource_id)
    end
    CollectData.perform_in(collect_interval.seconds, uri, resource_id,
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

  def new_sensor_value(value, collected_json, capability_id, resource_id)
    build = SensorValue.new
    build.value = value
    build.date = collected_json['updated_at']
    build.capability_id = capability_id
    build.platform_resource_id = resource_id
    # TODO: Use log class
    puts 'error' unless build.save
  end

  def get_capability_id(capability_name)
    capability_id = $redis.get(capability_name)
    unless capability_id
      current_capability = Capability.find_by_name(capability_name)
      return nil unless current_capability
      $redis.set(capability_name, current_capability.id)
      return current_capability.id
    end
    capability_id
  end
end
