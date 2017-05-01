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

  validate :collaborator_state_present

  STATES = {
    invited: 'invited',
    interested: 'interested',
    collaborator: 'collaborator'
  }.freeze

  def collaborator_state_present
    errors.add('must specify how the user is collaborating') if
      [invited_at, interested_at].compact.count.zero?
  end

  def state
    return STATES[:collaborator] if invited_at && interested_at
    return STATES[:invited] if invited_at
    return STATES[:interested] if interested_at
    nil
  end
end
