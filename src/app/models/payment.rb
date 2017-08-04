class Payment < ApplicationRecord
  belongs_to :job
  belongs_to :estimate
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'
  belongs_to :chargee, foreign_key: :chargee_id, class_name: 'User'

  def self.complete(job)
    awarded_user = job.awarded_user.first
    raise Zanza::PaymentPreConditionsNotMet, 'No one has been awarded the job' unless awarded_user

    estimate = job.collaborators.find_by(user: awarded_user).estimate
    raise Zanza::PaymentPreConditionsNotMet, 'No estimate associated with job' unless estimate

    raise Zanza::PaymentPreConditionsNotMet, 'Payment token should be created before charging' unless job.payment_token
    charge = charge_token(job, estimate)
    save_payment_response(charge, job, estimate)
  end

  def self.charge_token(job, estimate)
    Rails.logger.info "About to charge token - #{job.payment_token.token['id']}"
    charge = Stripe::Charge.create(
      amount: estimate.total_cents,
      currency: estimate.total_currency,
      source: job.payment_token.token['id'],
      description: "charge for job #{job.id}"
    )
    Rails.logger.info "Stripe charge response - #{charge}"
    charge
  end

  def self.save_payment_response(charge, job, estimate)
    payment = Payment.create(
      charge: charge,
      job: job,
      estimate: estimate,
      chargee: job.user,
      recipient: job.awarded_user.first
    )
    raise Zanza::PaymentException, charge['outcome'] unless charge['status'] == 'succeeded'
    payment
  end
end
