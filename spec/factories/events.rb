
FactoryGirl.define do
  
  factory :data do
    component_uuid "push"
    capability ""
    type ""
    unity ""
    value ""

    event
  end


  # create data to fill in the event after its creation
  factory :event do

    category "push"
    resource_id 152
    date DateTime.new(2016, 2, 3)

    factory :event_with_data do
      transient do
        data_count 1
      end

      after(:create) do |event, evaluator|
        create_list(:data, evaluator.data_count, event: event)
      end
  	end

  end
end