class Review < ApplicationRecord
  belongs_to :user
  belongs_to :subject, class_name: 'User'
  belongs_to :job
end
