class EstimatesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_authenticated_estimate, only: %i[update destroy]

  def create
    @job = Job.find(params[:job_id])
    @estimate = Estimate.create(estimate_create_params.merge(user_id: current_user.id))
    @job.add_collaborator(:interested, user: current_user) if @job.can_register_interested_user(current_user)

    render json: { data: @estimate }
  end

  def update
    @estimate.update!(estimate_update_params)
    render json: { data: @estimate.reload }
  end

  def destroy
    @estimate.destroy
    render json: { success: true }
  end

  # POST /estimates/:id/accept
  def accept
    estimate = Estimate.find(params[:id])
    raise Zanza::AuthorizationException, 'cannot accept an estimate for another persons job' unless
      current_user.jobs.include? estimate.job
    estimate.accept

    render json: { data: Estimate.where(job: estimate.job, user: estimate.user) }
  end

  def reject
    estimate = Estimate.find(params[:id])
    raise Zanza::AuthorizationException, 'cannot reject an estimate for another persons job' unless
      current_user.jobs.include? estimate.job
    estimate.reject

    render json: { data: Estimate.where(job: estimate.job, user: estimate.user) }
  end

  private

  def set_authenticated_estimate
    @estimate = current_user.estimates.find(params[:id])
  end

  def estimate_create_params
    estimate_update_params.merge(
      params.permit(:job_id).to_h
    )
  end

  def estimate_update_params
    params.permit(
      :days,
      :start_at,
      :end_at,
      :per_diem,
      :total
    ).to_h
  end
end
