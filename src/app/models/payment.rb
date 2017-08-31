class Payment < ApplicationRecord
  belongs_to :job
  belongs_to :estimate
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'
  belongs_to :chargee, foreign_key: :chargee_id, class_name: 'User'

  def self.complete(job)
    awarded_user = job.awarded_user
    raise Zanza::PaymentPreConditionsNotMet, 'No one has been awarded the job' unless awarded_user

    estimate = job.awarded_estimate
    raise Zanza::PaymentPreConditionsNotMet, 'No accepted estimate associated with job' unless estimate

    raise Zanza::PaymentPreConditionsNotMet, 'A payment card should be set before paying' unless job.payment_card_id
    charge = charge_job(job, estimate)
    save_payment_response(charge, job, estimate)
  end

  def self.charge_job(job, estimate)
    Rails.logger.info "About to charge card id - #{job.payment_card_id} - for user - #{job.user.id}"
    Stripe::Charge.create(
      amount: estimate.total_cents,
      currency: estimate.total_currency,
      customer: job.user.payment_account.customer['id'],
      source: job.payment_card_id,
      description: "charge for job #{job.id}"
    )
  rescue StandardError => e
    Rails.logger.info "Payment error - user: #{job.user.id}, job: #{job.id}, message: #{e.message}"
    raise Zanza::PaymentException, e.message
  end

  def self.save_payment_response(charge, job, estimate)
    Payment.create(
      charge: charge,
      job: job,
      estimate: estimate,
      chargee: job.user,
      recipient: job.awarded_user
    )
  end
end
