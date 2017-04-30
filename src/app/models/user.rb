class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  acts_as_paranoid
  acts_as_taggable

  include DeviseTokenAuth::Concerns::User

  has_many :jobs
  has_many :messages
  has_many :collaborating_jobs, through: :collaborators, source: :job
  has_many :collaborators

  def invite_to_jobs(jobs)
    add_collaborators(jobs, :invited_at)
  end

  def invited_to_jobs
    collaborating_jobs.merge(Collaborator.invited)
  end

  def register_interest_in_jobs(jobs)
    add_collaborators(jobs, :interested_at)
  end

  def interested_in_jobs
    collaborating_jobs.merge(Collaborator.interested)
  end

  def as_json(options = {})
    super(options).merge(tag_list: tag_list)
  end

  protected

  def confirmation_required?
    Rails.configuration.confirmation_required
  end

  def add_collaborators(jobs, state)
    time = Time.zone.now
    ary_jobs = Array(jobs)
    ary_jobs.map! { |job| { job: job, state => time } }
    collaborators.create(ary_jobs)
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info "trying to #{state} user #{user}"
  end
end
