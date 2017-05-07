#  Estimate isn't a model in the app, but can be used for attributes for filling out an estimate
#  being sent to a job. use `attributes_for(:estimate)` in tests
class Estimate
  attr_accessor :days, :start_date, :end_date, :per_diem, :total
end

FactoryGirl.define do
  factory :estimate do
    days { rand(10) }
    start_date { (Time.zone.now + 1.hour).change(usec: 0) }
    end_date { (Time.zone.now + days.day).change(usec: 0) }
    per_diem { rand(1000).round(-2) }
    total { per_diem * days }
  end
end
