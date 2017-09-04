FactoryGirl.define do
  sequence(:position_title) { |n| "position title-#{n}" }
  sequence(:position_summary) { |n| "position summary-#{n}" }
  sequence(:company) { |n| "company-#{n}" }

  factory :position do
    user { create(:user) }
    title { generate(:position_title) }
    summary { generate(:position_summary) }
    start_at { Time.zone.now - 2.years }
    end_at { Time.zone.now - 1.years }
    company { generate(:company) }
  end
end
