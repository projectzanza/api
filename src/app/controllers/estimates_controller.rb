class EstimatesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_estimate, only: %i[accept reject]
  before_action :set_authenticated_estimate, only: %i[update destroy]

  def create
    authorize! :create, Estimate

    @job = Job.find(params[:job_id])
    @estimate = Estimate.create(estimate_create_params.merge(user_id: current_user.id))

    @job.update_collaborator(:interested, user: current_user) if
      @job.update_collaborator?(:interested, user: current_user)

    render json: { data: @estimate }
  end

  def update
    authorize! :update, @estimate

    @estimate.update!(estimate_update_params)
    render json: { data: @estimate.reload }
  end

  def destroy
    authorize! :destroy, @estimate

    @estimate.destroy
    render json: { success: true }
  end

  # POST /estimates/:id/accept
  def accept
    authorize! :accept, @estimate

    @estimate.accept
    render json: { data: Estimate.where(job: @estimate.job, user: @estimate.user) }
  end

  def reject
    authorize! :reject, @estimate

    @estimate.reject
    render json: { data: Estimate.where(job: @estimate.job, user: @estimate.user) }
  end

  private

  def set_authenticated_estimate
    @estimate = current_user.estimates.find(params[:id])
  end

  def set_estimate
    @estimate = Estimate.find(params[:id])
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
