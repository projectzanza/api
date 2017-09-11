FactoryGirl.define do
  sequence :review_description do |n|
    "review description-#{n}"
  end

  factory :review do
    user { build(:user) }
    job { build(:job) }
    subject { build(:user) }
    description { generate(:review_description) }
    ability { rand(1..5) }
    communication { rand(1..5) }
    speed { rand(1..5) }
    overall { rand(1..5) }
  end
end
