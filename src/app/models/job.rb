class Job < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  has_many :messages

  validates :title, presence: true
end
