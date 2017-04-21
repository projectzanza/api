class Job < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  belongs_to :user
  has_many :messages
  has_and_belongs_to_many :selected_users,
                          join_table: 'selected_users_jobs',
                          class_name: 'User',
                          foreign_key: :user_id,
                          association_foreign_key: :job_id

  validates :title, presence: true
  validates :user, presence: true
  validates :proposed_start_at, in_future: true, on: :create
  validates :proposed_end_at, in_future: true, on: :create
  validate :proposed_end_at_after_proposed_start_at

  def as_json(options)
    super(options).merge(tag_list: tag_list)
  end

  def proposed_end_at_after_proposed_start_at
    errors.add(:proposed_end_at, 'cannot be before proposed start date') unless
      proposed_start_at.nil? || (proposed_end_at > proposed_start_at)
  end
end
