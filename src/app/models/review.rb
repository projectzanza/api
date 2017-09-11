class Review < ApplicationRecord
  belongs_to :user
  belongs_to :subject, class_name: 'User'
  belongs_to :job

  validate :one_per_user_per_job

  def one_per_user_per_job
    errors.add(:base, 'Only one review per user in each job') if
      new_record? && Review.where(job: job, user: user).count > 0
  end
end
