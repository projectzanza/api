class Job < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  validates :title, presence: true
end
