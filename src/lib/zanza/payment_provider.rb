class PaymentProvider
  class << self
    def add_card(user, token)
      customer =
        if user.payment_account
          Stripe::Customer.retrieve(user.payment_account.customer['id'])
        else
          cust = Stripe::Customer.create(email: user.email)
          user.create_payment_account(customer: customer)
          cust
        end
      customer.sources.create(source: token['id'])
    end
  end
end
