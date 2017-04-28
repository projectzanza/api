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
  has_and_belongs_to_many :invited_to_jobs,
                          join_table: 'invited_users_jobs',
                          class_name: 'Job',
                          foreign_key: :job_id,
                          association_foreign_key: :user_id do
    def << (value)
      # uniqueness constraint is in the db, but need to swallow it here
      super value rescue ActiveRecord::RecordNotUnique
    end
  end


  def as_json(options = {})
    super(options).merge(tag_list: tag_list)
  end

  protected

  def confirmation_required?
    Rails.configuration.confirmation_required
  end
end
