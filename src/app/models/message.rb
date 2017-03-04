class Message < ApplicationRecord
  acts_as_paranoid

  belongs_to :job
  belongs_to :user

  validates :text, presence: true
  validates :job_id, presence: true
end
