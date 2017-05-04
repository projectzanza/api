class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  acts_as_paranoid
  acts_as_taggable

  include DeviseTokenAuth::Concerns::User
  include HasCollaborator

  has_many :jobs
  has_many :messages
  has_many :collaborating_jobs, through: :collaborators, source: :job
  has_many :collaborators

  def invite_to_jobs(jobs)
    add_collaborators(jobs, :job, :invited_at)
  end

  def invited_to_jobs
    collaborating_jobs.merge(Collaborator.invited)
  end

  def register_interest_in_jobs(jobs)
    add_collaborators(jobs, :job, :interested_at)
  end

  def interested_in_jobs
    collaborating_jobs.merge(Collaborator.interested)
  end

  def prospective_jobs
    collaborating_jobs.merge(Collaborator.prospective)
  end

  def awarded_jobs
    collaborating_jobs.merge(Collaborator.awarded)
  end

  def accepted_jobs
    collaborating_jobs.merge(Collaborator.accepted)
  end

  def accept_job(job)
    add_collaborators(job, :job, :accepted_at)
  end

  def participant_jobs
    collaborating_jobs.merge(Collaborator.participant)
  end

  def default_collaborating_jobs
    job_results = invited_to_jobs.limit(5)
    job_results += interested_in_jobs.limit(5)
    job_results += prospective_jobs.limit(5)
    job_results += awarded_jobs.limit(5)
    job_results + participant_jobs.limit(5)
  end

  def find_collaborating_jobs(options = {})
    opts = HashWithIndifferentAccess.new(limit: 20).merge(options)
    filter = Collaborator::STATES[opts[:filter].to_sym] ? opts[:filter] : nil

    if filter
      collaborating_jobs.merge(Collaborator.send(filter)).limit(opts[:limit])
    else
      default_collaborating_jobs
    end
  end

  def as_json(options = {})
    meta = meta_as_json(options)
    options.delete(:job)
    super(options).merge(tag_list: tag_list, meta: meta)
  end

  def meta_as_json(options)
    if options[:job] && (collaborator = collaborators.where(job: options[:job]).first)
      {
        job: {
          collaboration_state: collaborator.state
        }
      }
    else
      {}
    end
  end

  protected

  #  a config option for devise
  def confirmation_required?
    Rails.configuration.confirmation_required
  end
end
