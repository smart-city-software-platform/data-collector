FactoryGirl.define do

  factory :detail do
    component_uuid "929fa69e-2837-11e6-b67b-9e71128cae77"
    event_id "123"
    capability "temperature"
    data_type "double"
    unit "celsius"  # Unit of measurement
    value "27"

    event
  end
end
