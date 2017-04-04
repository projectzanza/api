FactoryGirl.define do
  sequence :title do |n|
    "job-#{n}"
  end

  sequence :tag do |n|
    "tag-#{n}"
  end

  factory :job do
    title { generate(:title) }
    text { generate(:title) }
    tag_list { (0...3).collect{ generate(:tag) }}
    per_diem { rand(1000).round(-2) }

    trait :is_closed do
      closed_at { Time.zone.now }
    end
  end
end
