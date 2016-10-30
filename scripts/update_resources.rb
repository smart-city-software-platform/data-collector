#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'rubygems'
require 'json'

ENV['RAILS_ENV'] ||= 'development'

def update_resources
  conn = Bunny.new(hostname: 'rabbitmq')
  conn.start
  channel = conn.create_channel
  topic = channel.topic('resource_update')

  queue = channel.queue('data_collection')

  queue.bind(topic, routing_key: '#.sensor.#')

  begin
    queue.subscribe(:block => true) do |delivery_info, properties, body|
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
      
      begin
        resource = PlatformResource.find_by_uuid(json['uuid'])
        raise ActiveRecord::RecordNotFound unless resource
        resource.update!(resource_attributes)

        capabilities = json['capabilities']
        remove_needed_capabilities(capabilities, resource)

        assotiate_capability_with_resource(json['capabilities'], resource)
      rescue ActiveRecord::RecordNotFound => err
        LOGGER.error("Could not find resource with uuid #{json['uuid']}. #{err}")
      rescue ActiveRecord::RecordInvalid => invalid
        LOGGER.error("Attempt to store resource: #{invalid.record.errors}")
      end
    end
  rescue Interrupt => _
    channel.close
    conn.close
  end
end

def assotiate_capability_with_resource(capabilities, resource)
  if capabilities.kind_of? Array
    capabilities.each do |capability_name|
      # Thread safe
      begin
        capability = Capability.find_or_create_by(name: capability_name)
      rescue ActiveRecord::RecordNotUnique => err
        LOGGER.info("Attempt to create duplicated capability. #{err}")
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

update_resources
