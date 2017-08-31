class Estimate < ApplicationRecord
  acts_as_paranoid

  monetize :total_cents
  monetize :per_diem_cents

  belongs_to :job
  belongs_to :user

  validates :job, presence: true
  validates :user, presence: true
  validate :readonly_policy

  state_machine :state, initial: :submitted do
    before_transition any => any do |estimate, transition|
      case transition.event
      when :accept
        job_estimates = estimate.job.estimates.to_a.delete_if { |e| e == estimate }
        job_estimates.each(&:reject)
        estimate.accepted_at = Time.zone.now
      when :reject
        estimate.rejected_at = Time.zone.now
      end
    end

    event :accept do
      transition %i[submitted rejected] => :accepted
    end

    event :reject do
      transition %i[submitted accepted] => :rejected
    end
  end

  def readonly_policy
    allow_change = %w[accepted_at rejected_at state]
    return true if (allow_change | changed).length == allow_change.length
    errors.add(:state, 'cannot update state once accepted') if state_was == 'accepted'
  end

  def as_json(options = {})
    extra = {
      state: state,
      per_diem: per_diem.format,
      total: total.format
    }

    super(options).merge(extra)
  end
end
