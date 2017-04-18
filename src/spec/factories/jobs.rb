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
    tag_list { (0...3).collect { generate(:tag) } }
    per_diem do
      {
        min: rand(500).round(-2),
        max: rand(1000 + 500).round(-2)
      }
    end
    proposed_start_at { Time.zone.now + 1.hour }
    proposed_end_at { Time.zone.now + 1.day }

    trait :is_closed do
      closed_at { Time.zone.now }
    end
  end
end
