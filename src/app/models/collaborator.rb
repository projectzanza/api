class Collaborator < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :state, presence: true
  validate :one_awarded_user_per_job

  def initialize(*)
    super
  end

  state_machine :state, initial: :init do
    before_transition any => any do |collaborator, transition|
      case transition.event
      when :invite
        collaborator.invited_at = Time.zone.now
      when :interested
        collaborator.interested_at = Time.zone.now
      when :award
        collaborator.awarded_at = Time.zone.now
      when :accept
        collaborator.accepted_at = Time.zone.now
      when :reject
        collaborator.rejected_at = Time.zone.now
      end
    end

    event :invite do
      transition init: :invited,
                 interested: :prospective
    end

    event :interested do
      transition init: :interested,
                 invited: :prospective
    end

    event :award do
      transition %i[init interested invited prospective rejected] => :awarded
    end

    event :accept do
      transition awarded: :accepted
    end

    event :reject do
      transition any => :rejected
    end
  end

  def one_awarded_user_per_job
    errors.add(:state, 'can only award to one user at a time') if
      state == 'awarded' && Collaborator.where(job: job, state: :awarded).count > 1
  end
end
