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

  STATES = {
    open: 'open',
    closed: 'closed',
    complete: 'completed'
  }.freeze

  def state
    return STATES[:closed] if closed_at
    return STATES[:complete] if verified_at
    STATES[:open]
  end

  def invite_user(user)
    add_collaborator(:invite, user: user)
  end

  def invited_users
    collaborating_users.merge(Collaborator.with_state(:invited))
  end

  def register_interested_user(user)
    add_collaborator(:interested, user: user)
  end

  def can_register_interested_user(user)
    !collaborators.find_by(user: user) || collaborators.find_by(user: user).can_interested?
  end

  def interested_users
    collaborating_users.merge(Collaborator.with_state(:interested))
  end

  def prospective_users
    collaborating_users.merge(Collaborator.with_state(:prospective))
  end

  def award_to_user(user)
    add_collaborator(:award, user: user)
  end

  def awarded_user
    collaborating_users.merge(Collaborator.with_state(:awarded)).first
  end

  def awarded_users
    collaborating_users.merge(Collaborator.with_state(:awarded))
  end

  def accepted_by(user)
    add_collaborator(:accept, user: user)
  end

  def participant_users
    collaborating_users.merge(Collaborator.with_state(:participant))
  end

  def reject_user(user)
    collaborators.find_by(user: user).reject
  end

  def awarded_estimate
    estimates.where(user: awarded_user).find { |estimate| estimate.state == 'accepted' }
  end

  def default_collaborating_users
    invited_users.limit(5)
                 .union_all(interested_users.limit(5))
                 .union_all(prospective_users.limit(5))
                 .union_all(awarded_users)
                 .union_all(participant_users.limit(5))
  end

  def find_collaborating_users(options = {})
    opts = HashWithIndifferentAccess.new(limit: 20).merge(options)
    if opts[:state]
      collaborating_users.merge(Collaborator.with_state(opts[:state])).limit(opts[:limit])
    else
      default_collaborating_users
    end
  end

  def verify(options)
    unless options[:user] == user
      raise Zanza::AuthorizationException,
            'User does not have permission to verify job'
    end
    update_attributes(verified_at: Time.zone.now)
    scopes.each { |s| s.verify!(options[:user]) } if options[:scopes]
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
