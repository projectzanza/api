class PaymentProviderChargeResponse
  attr_accessor :id, :outcome
  def save
    true
  end
end

FactoryGirl.define do
  sequence :charge_id do |_n|
    "tok-#{SecureRandom.hex}"
  end

  factory :payment_provider_charge_response do
    transient do
      success true
    end

    id { generate(:charge_id) }
    object 'token'
    status { success ? 'succeeded' : 'failed' }
    outcome 'outcome'
  end
end
