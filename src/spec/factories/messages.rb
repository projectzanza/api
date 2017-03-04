FactoryGirl.define do
  factory :message do
    sequence :text do |n|
      "message-#{n}"
    end
  end
end
