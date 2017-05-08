class Estimate < ApplicationRecord
  monetize :total_cents
  monetize :per_diem_cents

  has_one :collaborator
  has_one :job, through: :collaborator
  has_one :user, through: :collaborator

  def as_json(options = {})
    extra = {
      job_id: job.id,
      user_id: user.id,
      per_diem: per_diem.format,
      total: total.format
    }

    super(options).merge(extra)
  end
end
