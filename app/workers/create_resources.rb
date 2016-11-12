require 'bunny'
require 'rubygems'
require 'json'

class CreateResources
  include Sidekiq::Worker

  TOPIC = 'resource_create'
  QUEUE = 'data_collection_resource_create'

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

          create_resource(resource_attributes, json)
          LOGGER.info("ResourcesCreate: Resource Created: #{resource_attributes}")
        end
      rescue Exception => e
        RESOURCE_LOGGER.error("ResourcesCreate: channel closed - #{e.message}")
      end
    end
  end
  
  private
  
  def create_resource(resource_attributes, json)
    begin
      resource = PlatformResource.new(resource_attributes)
      resource.save!
      assotiate_capability_with_resource(json['capabilities'], resource)
    rescue ActiveRecord::RecordNotUnique => err
      RESOURCE_LOGGER.error("ResourcesCreate: Error when tried to create resource. #{err}")
    rescue ActiveRecord::RecordInvalid => invalid
      RESOURCE_LOGGER.error("ResourcesCreate: Attempt to store resource: #{invalid.record.errors}")
    end
  end

  def assotiate_capability_with_resource(capabilities, resource)
    if capabilities.kind_of? Array
      capabilities.each do |capability_name|
        # Thread safe
        begin
          capability = Capability.find_or_create_by(name: capability_name)
        rescue ActiveRecord::RecordNotUnique => err
          RESOURCE_LOGGER.info("ResourcesCreate: Attempt to create duplicated capability. #{err}")
          capability = Capability.find_by_name(capability_name)
        end

        unless resource.capabilities.include?(capability)
          resource.capabilities << capability
        end
      end
    end
  end
end
