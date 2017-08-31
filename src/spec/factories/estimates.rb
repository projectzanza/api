FactoryGirl.define do
  factory :estimate do
    days { rand(1..10) }
    start_at { (Time.zone.now + 1.hour).change(usec: 0) }
    end_at { (Time.zone.now + days.day).change(usec: 0) }
    per_diem { rand(10..1000).round(-2) }
    total { per_diem * days }
    job { create(:job) }
    user { create(:user) }
  end
end
