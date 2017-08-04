class PaymentsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!

  def token
    job = current_user.jobs.find(params[:job_id])
    job.create_payment_token(
      user: current_user,
      token: params[:token]
    )

    render json: { data: job.reload.payment_token }
  end

  def complete
    job = current_user.jobs.find(params[:job_id])
    payment = Payment.complete(job)
    render json: { data: payment }
  end
end
