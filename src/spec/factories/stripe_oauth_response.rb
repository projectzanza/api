class StripeOauthResponse
  def save!
    true
  end
end

FactoryGirl.define do
  factory :stripe_oauth_response do
    access_token { SecureRandom.hex }
    scope 'read_only'
    refresh_token { SecureRandom.hex }
    stripe_user_id { SecureRandom.hex }
    stripe_publishable_key { SecureRandom.hex }
  end
end
