class PaymentsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!

  def token
    job = current_user.jobs.find(params[:job_id])
    if params[:token]
      card = current_user.add_card(params[:token])
      job.update_attributes!(payment_card_id: card['id'])
    elsif current_user.card?(params[:card])
      job.update_attributes!(payment_card_id: params[:card])
    else
      raise ActiveRecord::RecordNotFound, 'the card specified was not found'
    end

    render json: { success: true }
  end

  def cards
    render json: { data: current_user.cards }
  end

  def complete
    job = current_user.jobs.find(params[:job_id])
    Payment.complete(job)
    render json: { success: true }
  end
end
