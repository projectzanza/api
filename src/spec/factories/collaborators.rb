FactoryGirl.define do
  factory :collaborator do
    user { create(:user) }
    job { create(:job) }
  end
end
