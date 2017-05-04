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

  def scope_params
    params.permit(
      :title,
      :description
    ).to_h
  end
end
