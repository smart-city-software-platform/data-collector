FactoryGirl.define do
  factory :sensor_value do
    value "68.6345"
    date "2016-06-16 20:43:13"
    
    association :platform_resource, factory: :essential_args
    association :capability, factory: :capability
  end
end
