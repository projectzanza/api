FactoryGirl.define do
  sequence :scope_title do |n|
    "title-#{n}"
  end

  sequence :scope_description do |n|
    "description-#{n}"
  end

  factory :scope do
    job { create(:job) }
    title { generate(:scope_title) }
    description { generate(:scope_description) }
  end
end
