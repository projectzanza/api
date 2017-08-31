class ScopesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_authenticated_scope, only: %i[update reject verify destroy]

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

  # PUT /scopes/:id
  def update
    @scope.update(scope_params)
    render json: { data: @scope.reload }
  end

  # POST /scopes/:id/complete
  def complete
    @scope = Scope.find(params[:id])
    raise Zanza::AuthorizationException unless [@scope.job.user, @scope.job.awarded_user].include? current_user
    @scope.complete

    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/reject
  def reject
    @scope.reject

    render json: { data: @scope.job.scopes }
  end

  # POST /scopes/:id/verify
  def verify
    @scope.verify

    render json: { data: @scope.reload.job.scopes }
  end

  # DELETE /scopes/:id
  def destroy
    @scope.destroy
    render json: { success: true }
  end

  private

  def set_authenticated_scope
    @scope = Scope.find(params[:id])
    raise Zanza::AuthorizationException unless @scope.job.user == current_user
    @scope
  end

  def scope_params
    params.permit(
      :title,
      :description
    ).to_h
  end
end
