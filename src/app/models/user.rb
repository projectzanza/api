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

  def as_json(options = {})
    super(options).merge(tag_list: tag_list)
  end

  protected

  def confirmation_required?
    Rails.configuration.confirmation_required
  end
end
