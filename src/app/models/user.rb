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

  def awarded_jobs
    collaborating_jobs.merge(Collaborator.awarded)
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

  def confirmation_required?
    Rails.configuration.confirmation_required
  end
end
