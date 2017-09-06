class ScopesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_scope, only: %i[update complete reject verify destroy]

  # GET /jobs/:job_id/scopes
  def index
    authorize! :list, Scope
    @job = Job.find(params[:job_id])
    render json: { data: @job.scopes }
  end

  # POST /jobs/:job_id/scopes
  def create
    authorize! :create, Scope

    @job = current_user.jobs.find(params[:job_id])
    scope = Scope.new(scope_params)
    @job.scopes << scope

    render json: { data: @job.reload.scopes }
  end

  # PUT /scopes/:id
  def update
    authorize! :update, @scope

    @scope.update(scope_params)
    render json: { data: @scope.reload }
  end

  # POST /scopes/:id/complete
  def complete
    authorize! :complete, @scope

    @scope.complete
    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/reject
  def reject
    authorize! :reject, @scope

    @scope.reject
    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/verify
  def verify
    authorize! :verify, @scope

    @scope.verify
    render json: { data: @scope.reload.job.scopes }
  end

  # DELETE /scopes/:id
  def destroy
    authorize! :destroy, @scope

    @scope.destroy
    render json: { success: true }
  end

  private

  def set_scope
    @scope = Scope.find(params[:id])
  end

  def scope_params
    params.permit(
      :title,
      :description
    ).to_h
  end
end
