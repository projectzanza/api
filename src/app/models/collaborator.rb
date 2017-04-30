class Collaborator < ApplicationRecord
  belongs_to :user
  belongs_to :job

  scope :invited, -> { where.not(collaborators: { invited_at: nil }) }
  scope :interested, lambda {
    where(collaborators: { invited_at: nil })
      .where.not(collaborators: { interested_at: nil })
  }
end
