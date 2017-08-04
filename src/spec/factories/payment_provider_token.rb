class PaymentProviderToken
  attr_accessor :id, :object, :card
  def save
    true
  end
end

FactoryGirl.define do
  sequence :token_id do |_n|
    "tok-#{SecureRandom.hex}"
  end

  sequence :card_id do |_n|
    SecureRandom.hex
  end

  factory :payment_provider_token do
    id { generate(:token_id) }
    object 'token'
    card do
      {
        id: generate(:card_id),
        object: 'card',
        brand: 'Visa',
        country: 'US',
        cvc_check: 'unchecked',
        dynamic_last4: 'null',
        exp_month: 11,
        exp_year: 2019,
        funding: 'credit',
        last4: '4242',
        name: 'null',
        tokenization_method: 'null'
      }
    end
  end
end
