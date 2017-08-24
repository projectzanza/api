class EstimatesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_authenticated_estimate, only: %i[update destroy]

  def create
    @job = Job.find(params[:job_id])
    @estimate = Estimate.create(estimate_create_params.merge(user_id: current_user.id))
    @job.add_collaborators(current_user, :user, :interested_at)

    render json: { data: @estimate }
  end

  def update
    @estimate.update_attributes!(estimate_update_params)
    render json: { data: @estimate.reload }
  end

  def destroy
    @estimate.destroy
    render json: { success: true }
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
