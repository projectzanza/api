class Estimate < ApplicationRecord
  acts_as_paranoid

  monetize :total_cents
  monetize :per_diem_cents

  belongs_to :job
  belongs_to :user

  validates :job, presence: true
  validates :user, presence: true
  validate :readonly_policy

  STATES = {
    submitted: 'submitted',
    accepted: 'accepted',
    rejected: 'rejected'
  }.freeze

  def state
    return STATES[:accepted] if accepted_at
    return STATES[:rejected] if rejected_at
    STATES[:submitted]
  end

  def readonly_policy
    allow_change = %w[accepted_at rejected_at]
    errors.add(:base, 'cannot update estimate once accepted') if
      state == STATES[:accepted] &&
      (allow_change.length - changed.length) != (allow_change - changed).length
  end

  def accept
    job_estimates = job.estimates.where(user: user)
    job_estimates.each(&:reject)
    update!(accepted_at: Time.zone.now, rejected_at: nil)
  end

  def reject
    update!(accepted_at: nil, rejected_at: Time.zone.now) if state != STATES[:rejected]
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
