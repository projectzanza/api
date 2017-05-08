class Job < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  include HasCollaborator

  belongs_to :user
  has_many :messages
  has_many :collaborators
  has_many :collaborating_users, through: :collaborators, source: :user
  has_many :estimates, through: :collaborators
  has_many :scopes

  validates :title, presence: true
  validates :user, presence: true
  validates :proposed_start_at, in_future: true, on: :create
  validates :proposed_end_at, in_future: true, on: :create
  validate :proposed_end_at_after_proposed_start_at

  def invite_users(users)
    add_collaborators(users, :user, :invited_at)
  end

  def invited_users
    collaborating_users.merge(Collaborator.invited)
  end

  def register_interested_users(users)
    add_collaborators(users, :user, :interested_at)
  end

  def interested_users
    collaborating_users.merge(Collaborator.interested)
  end

  def prospective_users
    collaborating_users.merge(Collaborator.prospective)
  end

  def award_to_user(user)
    add_collaborators(user, :user, :awarded_at)
  end

  def awarded_user
    collaborating_users.merge(Collaborator.awarded).limit(1)
  end

  def participant_users
    collaborating_users.merge(Collaborator.participant)
  end

  def reject_user(user)
    collaborators.find_by(user: user).reject
  end

  def estimate(user, estimate)
    collaborators.find_by(user: user).update_attributes!(estimate)
  end

  def default_collaborating_users
    invited_users.limit(5)
                 .union_all(interested_users.limit(5))
                 .union_all(prospective_users.limit(5))
                 .union_all(awarded_user)
                 .union_all(participant_users.limit(5))
  end

  def find_collaborating_users(options = {})
    opts = HashWithIndifferentAccess.new(limit: 20).merge(options)
    filter = opts[:filter] && Collaborator::STATES[opts[:filter].to_sym] ? opts[:filter] : nil

    if filter
      collaborating_users.merge(Collaborator.send(filter)).limit(opts[:limit])
    else
      default_collaborating_users
    end
  end

  def as_json(options)
    meta = meta_as_json(options)
    options.delete(:user)
    super(options).merge(tag_list: tag_list, meta: meta)
  end

  def meta_as_json(options)
    if options[:user] && (collaborator = collaborators.where(user: options[:user]).first)
      {
        current_user: {
          collaboration_state: collaborator.state,
          estimate: collaborator.estimate.as_json
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
