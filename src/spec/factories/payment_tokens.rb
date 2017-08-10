FactoryGirl.define do
  factory :payment_token do
    token { FactoryGirl.attributes_for(:payment_provider_token) }
  end
end
