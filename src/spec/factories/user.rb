FactoryGirl.define do
  sequence :nickname do |n|
    "user#{n}"
  end

  factory :user do
    email { "#{generate(:nickname)}@test.com" }
    nickname { generate(:nickname) }
    password '123123123'
    password_confirmation '123123123'
    headline 'headline'
    summary 'summary'
  end
end
