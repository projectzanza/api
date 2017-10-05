class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  acts_as_paranoid
  acts_as_taggable
  has_attached_file :avatar,
                    default_url: '/assets/images/defaults/:style/avatar.png'

  include DeviseTokenAuth::Concerns::User

  has_many :jobs
  has_many :positions
  has_many :collaborators
  has_many :collaborating_jobs, through: :collaborators, source: :job
  has_many :estimates
  has_many :reviews, class_name: 'Review', foreign_key: :subject_id
  has_many :written_reviews, class_name: 'Review', foreign_key: :user_id
  has_one :payment_account

  scope :filter, lambda { |string|
    where('email ILIKE ?', "%#{string}%")
      .or(where('nickname ILIKE ?', "%#{string}%"))
      .or(where('name ILIKE ?', "%#{string}%"))
  }

  before_validation(on: :create) do
    if email && email.split('@')[0]
      email_identifier = email.split('@')[0]

      self.name ||= email_identifier
      self.nickname ||= "#{email_identifier}#{rand(100..999)}"
    end

    self.rc_password ||= SecureRandom.hex
  end

  validates :name, presence: true
  validates :nickname, presence: true
  validates :email, presence: true
  validates :rc_password, presence: true

  validates_attachment :avatar,
                       content_type: { content_type: %w[image/jpeg image/gif image/png] },
                       size: { in: 0..10.megabytes }

  def avatar_upload_url=(url_value)
    self.avatar = URI.parse(url_value)
    super url_value
  end

  def invited_to_jobs
    collaborating_jobs.where(collaborators: { state: 'invited' })
  end

  def interested_in_jobs
    collaborating_jobs.where(collaborators: { state: 'interested' })
  end

  def prospective_jobs
    collaborating_jobs.where(collaborators: { state: 'prospective' })
  end

  def awarded_jobs
    collaborating_jobs.where(collaborators: { state: 'awarded' })
  end

  def accepted_jobs
    collaborating_jobs.where(collaborators: { state: 'accepted' })
  end

  def default_collaborating_jobs
    invited_to_jobs.limit(5)
                   .union_all(interested_in_jobs.limit(5))
                   .union_all(prospective_jobs.limit(5))
                   .union_all(awarded_jobs.limit(5))
                   .union_all(accepted_jobs.limit(5))
  end

  def find_collaborating_jobs(options = {})
    opts = HashWithIndifferentAccess.new(limit: 20).merge(options)

    if opts[:state]
      collaborating_jobs.merge(Collaborator.with_state(opts[:state])).limit(opts[:limit])
    else
      default_collaborating_jobs
    end
  end

  def add_card(token)
    customer =
      if payment_account
        Stripe::Customer.retrieve(payment_account.customer['id'])
      else
        cust = Stripe::Customer.create(email: email)
        create_payment_account(customer: cust)
        cust
      end
    customer.sources.create(source: token['id'])
  end

  def card?(card_id)
    return false unless payment_account && payment_account.customer['id']
    begin
      customer = Stripe::Customer.retrieve(payment_account.customer['id'])
      true if customer.sources.retrieve(card_id)
    rescue Stripe::InvalidRequestError
      return false
    end
  end

  def cards
    return [] unless payment_account
    customer = Stripe::Customer.retrieve(payment_account.customer['id'])
    cards = customer.sources.all(object: :card)
    cards.data.collect do |details|
      {
        id: details['id'],
        brand: details['brand'],
        last4: details['last4'],
        exp_year: details['exp_year']
      }
    end
  end

  def as_json(options = {})
    meta = meta_as_json(options)
    options.delete(:job)
    options[:only] = %i[id created_at deleted_at email headline name nickname per_diem summary uid updated_at]
    super(options).merge(
      avatar_url: avatar.url,
      tag_list: tag_list,
      meta: meta
    )
  end

  def meta_as_json(options)
    if options[:job] && (collaborator = collaborators.where(job: options[:job]).first)
      {
        job: {
          collaboration_state: collaborator.state,
          estimates: estimates.where(job: options[:job])
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
