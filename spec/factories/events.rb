FactoryGirl.define do

  # Create detail to fill in the event after its creation
  factory :event do

    category "push"
    resource_id 152
    date DateTime.new(2016, 2, 3)

    factory :event_with_details do
      transient do
        details_count 1
      end

      after(:create) do |event, evaluator|
        create_list(:detail, evaluator.details_count, event: event)
      end
    end

  end
end
