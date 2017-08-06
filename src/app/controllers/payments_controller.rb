class PaymentsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!

  def token
    job = current_user.jobs.find(params[:job_id])
    card = current_user.add_card(params[:token])
    job.update_attributes!(payment_card_id: card['id'])

    render json: { success: true }
  end

  def complete
    job = current_user.jobs.find(params[:job_id])
    Payment.complete(job)
    render json: { success: true }
  end
end
