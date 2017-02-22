class Job < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  has_many :replies

  validates :title, presence: true
end
