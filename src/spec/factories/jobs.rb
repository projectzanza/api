FactoryGirl.define do
  sequence :title do |n|
    "job-#{n}"
  end

  factory :job do
    title { generate(:title) }
    text { generate(:title) }

    trait :is_closed do
      closed_at { Time.zone.now }
    end
  end
end
