require 'bunny'
require 'rubygems'
require 'json'
require 'mongoid'
require "#{File.dirname(__FILE__)}/../models/platform_resource"
require "#{File.dirname(__FILE__)}/../models/sensor_value"
require "#{File.dirname(__FILE__)}/../models/last_sensor_value"

class CollectData
  include Sidekiq::Worker
  sidekiq_options queue: 'collect_data', backtrace: true

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

      begin
        @queue.subscribe(:block => true) do |delivery_info, properties, body|
          routing_keys = delivery_info.routing_key.split('.')
          uuid = routing_keys.first
          resource = PlatformResource.find_by(uuid: uuid)
          if resource.nil?
            logger.error("CollectData: Could not find resource #{uuid}")
          end

          capability = routing_keys.last
          unless resource.capabilities.include? capability
            resource.capabilities << capability
            logger.info("CollectData: Capability #{capability} associated with resource #{uuid}")
          end

          create_sensor_value(resource, capability, body)
          logger.info("CollectData: Data Created: #{resource.uuid} - #{capability}")
        end
      rescue Exception => e
        logger.error("CollectData: channel closed - #{e.message}")
        @conn.close
        CollectData.perform_in(1.second)
      end
  end

  private

  def create_sensor_value(resource, capability, body)
    if resource && capability
      json = JSON.parse(body)
      value = SensorValue.new(
        uuid: resource.uuid,
        capability: capability,
        value: json['value'],
        date: json['timestamp'],
        platform_resource_id: resource.id
      )

      if !value.save
        logger.error("CollectData: Cannot save: #{value.inspect} with body #{body}")
      end
    end
  end
end
