FactoryGirl.define do
  sequence :scope_title do |n|
    "scope title-#{n}"
  end

  sequence :scope_description do |n|
    "scope description-#{n}"
  end

  factory :scope do
    job { create(:job) }
    title { generate(:scope_title) }
    description { generate(:scope_description) }
  end
end
