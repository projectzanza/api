class Scope < ApplicationRecord
  acts_as_paranoid

  belongs_to :job

  validates :state, presence: true

  def initialize(*)
    super
  end

  state_machine :state, initial: :open do
    before_transition any => any do |scope, transition|
      case transition.event
      when :complete
        scope.completed_at = Time.zone.now
      when :verify
        scope.verified_at = Time.zone.now
      when :reject
        scope.rejected_at = Time.zone.now
      end
    end

    event :complete do
      transition open: :completed,
                 rejected: :completed
    end

    event :verify do
      transition any => :verified
    end

    event :reject do
      transition any => :rejected
    end
  end

  def as_json(options)
    super(options).merge(state: state)
  end
end
