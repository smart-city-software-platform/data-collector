# frozen_string_literal: true
FactoryGirl.define do
  factory :sensor_value do
    factory :default_sensor_value do

      date '2016-06-16 20:43:13'
      capability "temperature"
      association :platform_resource, factory: :essential_args
    end
    factory :default_sensor_value_2 do
    
      date '2016-06-16 20:43:13'
      capability "temperature"
      association :platform_resource, factory: :resource_default_2
    end
  end
end
