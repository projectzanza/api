FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end

  factory :user do
    email { "#{generate(:username)}@test.com" }
    password '123123123'
    password_confirmation '123123123'
  end
end
