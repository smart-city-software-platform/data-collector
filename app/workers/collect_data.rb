require 'bunny'
require 'rubygems'
require 'json'

class CollectData
  include Sidekiq::Worker

  TOPIC = 'data_stream'
  QUEUE = 'data_collection'

  def initialize
    @conn = Bunny.new(hostname: SERVICES_CONFIG['services']['rabbitmq'])
    @conn.start
    @channel = @conn.create_channel
    @topic = @channel.topic(TOPIC)
    @queue = @channel.queue(QUEUE)
  end

  def perform
    @queue.bind(@topic, routing_key: '#')

    while true
      begin
        @queue.subscribe(:block => true) do |delivery_info, properties, body|
          routing_keys = delivery_info.routing_key.split('.')
          uuid = routing_keys.first
          resource = PlatformResource.find_by_uuid(uuid)
          if resource.nil?
            LOGGER.error("CollectData: Could not find resource #{uuid}")
          end

          capability_name = routing_keys.last
          capability = Capability.find_or_initialize_by(name: capability_name)
          if capability.new_record?
            # Avoid race condition
            begin
              capability.save!
            rescue ActiveRecord::RecordNotUnique
              capability = Capability.find_by_name(capability_name)
            end
            resource.capabilities << capability
            LOGGER.info("CollectData: Capability #{capability_name} created and associated with resource #{uuid}")
          end

          create_sensor_value(resource, capability, body)
          LOGGER.info("CollectData: Data Created: #{resource.uuid} - #{capability_name}")
        end
      rescue Exception => e
        LOGGER.error("CollectData: channel closed - #{e.message}")
      end
    end
  end

  private

  def create_sensor_value(resource, capability, body)
    if resource && capability
      json = JSON.parse(body)
      value = SensorValue.new(
        value: json['value'],
        date: json['timestamp'],
        capability_id: capability.id,
        platform_resource_id: resource.id
      )

      if !value.save
        LOGGER.error("CollectData: Cannot save: #{value.inspect} with body #{body}")
      end
    end
  end
end
