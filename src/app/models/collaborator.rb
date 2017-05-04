class Collaborator < ApplicationRecord
  belongs_to :user
  belongs_to :job

  scope :invited, lambda {
    where(collaborators: { awarded_at: nil, accepted_at: nil, interested_at: nil })
      .where.not(collaborators: { invited_at: nil })
  }
  scope :interested, lambda {
    where(collaborators: { invited_at: nil, awarded_at: nil, accepted_at: nil })
      .where.not(collaborators: { interested_at: nil })
  }
  scope :prospective, lambda {
    where.not(collaborators: { invited_at: nil, interested_at: nil })
  }
  scope :awarded, lambda {
    where(collaborators: { accepted_at: nil })
      .where.not(collaborators: { awarded_at: nil })
  }
  scope :accepted, -> { where.not(collaborators: { accepted_at: nil }) }
  scope :participant, lambda {
    where.not(collaborators: { accepted_at: nil, awarded_at: nil })
  }

  validate :collaborator_state_present
  validate :one_awarded_user_per_job
  validate :can_only_accept_awarded_job

  STATES = {
    participant: 'participant',
    awarded: 'awarded',
    prospective: 'prospective',
    invited: 'invited',
    interested: 'interested'
  }.freeze

  def collaborator_state_present
    errors[:base] << 'Collaborating state must be specified' if
      [invited_at, interested_at, awarded_at].compact.count.zero?
  end

  def one_awarded_user_per_job
    errors.add(:awarded_at, 'can only award to one user at a time') unless
      !awarded_at_was.nil? || Collaborator.where(job: job).where.not(awarded_at: nil).count.zero?
  end

  def can_only_accept_awarded_job
    errors.add(:accepted_at, 'can only accept an awarded job') if accepted_at && awarded_at_was.nil?
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def state
    return STATES[:participant] if awarded_at && accepted_at
    return STATES[:awarded] if awarded_at
    return STATES[:prospective] if invited_at && interested_at
    return STATES[:invited] if invited_at
    return STATES[:interested] if interested_at
    nil
  end
  # rubocop:enable all
end
