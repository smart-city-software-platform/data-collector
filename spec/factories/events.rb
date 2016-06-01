FactoryGirl.define do

  # Create detail to fill in the event after its creation
  factory :event do

    resource_uuid 'ab631116-2837-11e6-b67b-9e71128cae77'
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
