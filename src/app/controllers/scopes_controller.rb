class ScopesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!

  # GET /jobs/:job_id/scopes
  def index
    @job = Job.find(params[:job_id])
    render json: { data: @job.scopes }
  end

  # POST /jobs/:job_id/scopes
  def create
    @job = current_user.jobs.find(params[:job_id])
    @scope = Scope.create(scope_params.merge(job: @job))
    @job.reload

    render json: { data: @job.scopes }
  end

  # POST /scopes/:id/complete
  def complete
    @scope = Scope.find(params[:id])
    @scope.complete!(current_user)

    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/reject
  def reject
    @scope = Scope.find(params[:id])
    @scope.reject!(current_user)

    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/complete
  def verify
    @scope = Scope.find(params[:id])
    @scope.verify!(current_user)

    render json: { data: @scope.reload.job.scopes }
  end

  def scope_params
    params.permit(
      :title,
      :description
    ).to_h
  end
end
