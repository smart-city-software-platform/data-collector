FactoryGirl.define do
  factory :platform_resource do

    trait :default_no_capability do
      uri "http://localhost:3000/basic_resources/1/components/1/collect"
      uuid "ab631116-2837-11e6-b67b-9e71128cae77"
      status "on"
      collect_interval 60
    end

    trait :default_2_no_capability do
      uri "http://localhost:3000/basic_resources/491/components/300/collect"
      uuid "ab631116-2837-11e6-b67b-9e71128cae77"
      status "off"
      collect_interval 300
    end

    trait :typo_no_capability do
      uri "http://localhost:3000/basic_resources/2/components/2/collect"
      uuid "ab631116-2837-11e6-b67b-9e71128cae77"
      status "off"
      collect_intervallllll 60
    end

    trait :missing_argument do
      uri "http://localhost:3000/basic_resources/2/components/2/collect"
      uuid "ab631116-2837-11e6-b67b-9e71128cae77"
      status "off"
    end

  end
end
