class Position < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
end
