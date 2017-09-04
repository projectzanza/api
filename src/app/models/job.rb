class Job < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  include HasCollaborator

  belongs_to :user
  has_many :messages
  has_many :collaborators
  has_many :collaborating_users, through: :collaborators, source: :user
  has_many :estimates
  has_many :scopes

  validates :title, presence: true
  validates :user, presence: true
  validates :proposed_start_at, in_future: true, on: :create
  validates :proposed_end_at, in_future: true, on: :create
  validate :proposed_end_at_after_proposed_start_at

  state_machine :state, initial: :open do
    before_transition any => any do |job, transition|
      case transition.event
      when :verify
        job.verified_at = Time.zone.now
      when :complete
        job.completed_at = Time.zone.now
      end
    end

    event :verify do
      transition any => :verified
    end

    event :complete do
      transition open: :completed
    end
  end

  def invited_users
    collaborating_users.where(collaborators: { state: ['invited', 'prospective'] })
  end

  def interested_users
    collaborating_users.where(collaborators: { state: 'interested' })
  end

  def prospective_users
    collaborating_users.where(collaborators: { state: 'prospective' })
  end

  def awarded_user
    collaborating_users.find_by(collaborators: { state: 'awarded' })
  end

  def awarded_users
    collaborating_users.where(collaborators: { state: 'awarded' })
  end

  def accepted_users
    collaborating_users.where(collaborators: { state: 'accepted' })
  end

  def accepted_user
    collaborating_users.find_by(collaborators: { state: 'accepted' })
  end

  def awarded_estimate
    estimates.where(user: awarded_user).find { |estimate| estimate.state == 'accepted' }
  end

  def default_collaborating_users
    invited_users.limit(5)
                 .union_all(interested_users.limit(5))
                 .union_all(prospective_users.limit(5))
                 .union_all(awarded_users)
                 .union_all(accepted_users.limit(5))
  end

  def matching_users
    interested_users.union_all(User.tagged_with(tag_list)) - default_collaborating_users
  end

  def find_collaborating_users(options = {})
    opts = HashWithIndifferentAccess.new(limit: 20).merge(options)
    if opts[:state]
      collaborating_users.merge(Collaborator.with_state(opts[:state])).limit(opts[:limit])
    else
      default_collaborating_users
    end
  end

  def as_json(options)
    meta = meta_as_json(options)
    options.delete(:user)
    super(options).merge(
      tag_list: tag_list,
      state: state,
      meta: meta
    )
  end

  def meta_as_json(options)
    if options[:user] && (collaborator = collaborators.where(user: options[:user]).first)
      {
        current_user: {
          collaboration_state: collaborator.state,
          estimates: estimates.where(user: options[:user])
        }
      }
    else
      {}
    end
  end

  def proposed_end_at_after_proposed_start_at
    errors.add(:proposed_end_at, 'cannot be before proposed start date') unless
      proposed_start_at.nil? || (proposed_end_at > proposed_start_at)
  end
end
