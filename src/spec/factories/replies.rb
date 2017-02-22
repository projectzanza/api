FactoryGirl.define do
  factory :reply do
    sequence :text do |n|
      "reply-#{n}"
    end
  end
end
