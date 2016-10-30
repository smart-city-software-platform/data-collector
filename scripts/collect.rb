#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'rubygems'
require 'json'

ENV['RAILS_ENV'] ||= 'development'


conn = Bunny.new(hostname: 'rabbitmq')
conn.start
channel = conn.create_channel
topic = channel.topic('data_stream')

queue = channel.queue('data_collection')

queue.bind(topic, routing_key: '#')

begin
  queue.subscribe(:block => true) do |delivery_info, properties, body|
    routing_keys = delivery_info.routing_key.split('.')

    uuid = routing_keys.first
    resource = PlatformResource.find_by_uuid(uuid)
    if resource.nil?
      LOGGER.error("Could not find resource #{uuid}")
    end
    
    capability_name = routing_keys.last
    capability = Capability.find_by_name(capability_name)
    if capability.nil?
      LOGGER.error("Could not find capability #{capability_name}")
    end

    if resource && capability
      json = JSON.parse(body)
      value = SensorValue.new(
        value: json['value'],
        date: json['timestamp'],
        capability_id: capability.id,
        platform_resource_id: resource.id
      )

      if !value.save
        LOGGER.error("Cannot save: #{build.inspect}")
      end
    end
  end
rescue Interrupt => _
  channel.close
  conn.close
end
