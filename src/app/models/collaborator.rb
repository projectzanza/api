class Collaborator < ApplicationRecord
  belongs_to :user
  belongs_to :job

  scope :invited, -> { where.not(collaborators: { invited_at: nil }) }
  scope :interested, lambda {
    where(collaborators: { invited_at: nil })
      .where.not(collaborators: { interested_at: nil })
  }
  scope :collaborator, lambda {
    where.not(collaborators: { invited_at: nil })
         .where.not(collaborators: { interested_at: nil })
  }
  scope :awarded, -> { where.not(collaborators: { awarded_at: nil }) }

  validate :collaborator_state_present
  validate :one_awarded_user_per_job

  STATES = {
    awarded: 'awarded',
    invited: 'invited',
    interested: 'interested',
    collaborator: 'collaborator'
  }.freeze

  def collaborator_state_present
    errors[:base] << 'Collaborating state must be specified' if
      [invited_at, interested_at, awarded_at].compact.count.zero?
  end

  def one_awarded_user_per_job
    errors.add(:awarded_at, 'can only award to one user at a time') unless
      Collaborator.where(job: job).where.not(awarded_at: nil).count.zero?
  end

  def state
    return STATES[:awarded] if awarded_at
    return STATES[:collaborator] if invited_at && interested_at
    return STATES[:invited] if invited_at
    return STATES[:interested] if interested_at
    nil
  end
end
