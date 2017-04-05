class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  acts_as_paranoid

  include DeviseTokenAuth::Concerns::User

  has_many :jobs
  has_many :messages

  protected

  def confirmation_required?
    Rails.configuration.confirmation_required
  end
end
