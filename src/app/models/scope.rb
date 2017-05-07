class Scope < ApplicationRecord
  belongs_to :job

  STATES = {
    completed: 'completed',
    verified: 'verified',
    rejected: 'rejected',
    open: 'open'
  }.freeze

  def complete!(by_user)
    update_attributes!(completed_at: Time.zone.now, rejected_at: nil) if can_complete!(by_user)
  end

  def verify!(by_user)
    update_attributes!(verified_at: Time.zone.now, rejected_at: nil) if can_verify!(by_user)
  end

  def reject!(by_user)
    raise Zanza::ForbiddenException if state == STATES[:open]
    update_attributes!(rejected_at: Time.zone.now, verified_at: nil) if can_reject!(by_user)
  end

  def can_complete!(user)
    unless user == job.user || user == job.awarded_user.first
      raise Zanza::AuthorizationException, 'User does not have permission to complete scope'
    end
    true
  end

  def can_verify!(user)
    raise Zanza::AuthorizationException, 'User does not have permission to verify scope' unless user == job.user
    true
  end

  def can_reject!(user)
    raise Zanza::AuthorizationException, 'User does not have permission to verify scope' unless user == job.user
    true
  end

  def state
    return STATES[:verified] if verified_at
    return STATES[:rejected] if rejected_at
    return STATES[:completed] if completed_at
    STATES[:open]
  end

  def as_json(options)
    super(options).merge(state: state)
  end
end
