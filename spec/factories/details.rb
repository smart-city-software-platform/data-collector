FactoryGirl.define do

  factory :detail do
    component_uuid "15"
    event_id "123"
    capability "temperature"
    data_type "double"
    unit "celsius"  # Unit of measurement
    value "27"

    event
  end
end
