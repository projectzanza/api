class Job < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  belongs_to :user
  has_many :messages
  has_many :collaborators
  has_many :collaborating_users, through: :collaborators, source: :user

  validates :title, presence: true
  validates :user, presence: true
  validates :proposed_start_at, in_future: true, on: :create
  validates :proposed_end_at, in_future: true, on: :create
  validate :proposed_end_at_after_proposed_start_at

  def invite_users(users)
    add_collaborators(users, :invited_at)
  end

  def invited_users
    collaborating_users.merge(Collaborator.invited)
  end

  def register_interested_users(users)
    add_collaborators(users, :interested_at)
  end

  def interested_users
    collaborating_users.merge(Collaborator.interested)
  end

  def as_json(options)
    super(options).merge(tag_list: tag_list)
  end

  def proposed_end_at_after_proposed_start_at
    errors.add(:proposed_end_at, 'cannot be before proposed start date') unless
      proposed_start_at.nil? || (proposed_end_at > proposed_start_at)
  end

  private

  def add_collaborators(users, state)
    time = Time.zone.now
    ary_users = Array(users)
    ary_users.map! { |user| { user: user, state => time } }
    collaborators.create(ary_users)
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info "trying to #{state} user #{user}"
  end
end
