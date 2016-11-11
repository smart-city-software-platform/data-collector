require 'bunny'
require 'rubygems'
require 'json'

class UpdateResources
  include Sidekiq::Worker

  TOPIC = 'resource_update'
  QUEUE = 'data_collection_resource_update'

  def initialize
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
  end

  def perform
    @queue.bind(@topic, routing_key: '#.sensor.#')

    while true
      begin
        @queue.subscribe(:block => true) do |delivery_info, properties, body|
          routing_keys = delivery_info.routing_key.split('.')
          json = JSON.parse(body)
          resource_attributes = json.slice(
            'uri',
            'uuid',
            'status',
            'collect_interval',
            'created_at',
            'updated_at'
          )

          update_resource(resource_attributes, json)
        end
      rescue Exception => e
        RESOURCE_LOGGER.error("UpdateResources: channel closed - #{e.message}")
        sleep 1
        next
      end
    end
  end
  
  private
  
  def update_resource(resource_attributes, json)
    begin
      resource = PlatformResource.find_by_uuid(json['uuid'])
      raise ActiveRecord::RecordNotFound unless resource
      resource.update!(resource_attributes)

      capabilities = json['capabilities']
      remove_needed_capabilities(capabilities, resource)

      assotiate_capability_with_resource(json['capabilities'], resource)
    rescue ActiveRecord::RecordNotFound => err
      RESOURCE_LOGGER.error("ResourcesUpdate: Could not find resource with uuid #{json['uuid']}. #{err}")
    rescue ActiveRecord::RecordInvalid => invalid
      RESOURCE_LOGGER.error("ResourcesUpdate: Attempt to store resource: #{invalid.record.errors}")
    end
  end

  def assotiate_capability_with_resource(capabilities, resource)
    if capabilities.kind_of? Array
      capabilities.each do |capability_name|
        # Thread safe
        begin
          capability = Capability.find_or_create_by(name: capability_name)
        rescue ActiveRecord::RecordNotUnique => err
          RESOURCE_LOGGER.info("UpdateResources: Attempt to create duplicated capability. #{err}")
          capability = Capability.find_by_name(capability_name)
        end

        unless resource.capabilities.include?(capability)
          resource.capabilities << capability
        end
      end
    end
  end

  def remove_needed_capabilities(capabilities, resource)
    # If no capabilities are present inside hash, just remove all
    if capabilities.nil?
      resource.capabilities.delete_all
    else
      rm = resource.capabilities.where('name not in (?)', capabilities)
      resource.capabilities.delete(rm)
    end
  end
end
