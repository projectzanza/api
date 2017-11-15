class JobsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_job, only: %i[show accept register_interest complete]
  before_action :set_authenticated_job, only: %i[update destroy verify]

  # GET /jobs
  def index
    authorize! :list, Job

    @jobs =
      if params[:user_id]
        User.find(params[:user_id]).jobs
      else
        @jobs = Job.all
      end

    render json: { data: @jobs }
  end

  # GET /jobs/1
  def show
    authorize! :read, @job

    render json: { data: @job.as_json(user: current_user) }
  end

  # POST /jobs
  def create
    authorize! :create, Job

    job_create_service = JobCreateService.new(current_user, job_params)
    job_create_service.call

    render json: { data: job_create_service.job }, status: :created, location: job_create_service.job
  end

  # PATCH/PUT /jobs/1
  def update
    authorize! :update, @job

    render json: { data: @job } if @job.update!(job_params)
  end

  # DELETE /jobs/1
  def destroy
    authorize! :destroy, @job
    @job.destroy
  end

  # GET /users/:user_id/jobs/match
  def match
    authorize! :list, Job

    @user = User.find(params[:user_id])
    @jobs = Job.where(allow_contact: true)
               .where.not(user_id: params[:user_id])
               .tagged_with(@user.tag_list)
    render json: { data: @jobs }
  end

  # GET /jobs/collaborating
  def collaborating
    authorize! :list, Job

    @jobs = current_user.find_collaborating_jobs(collaborating_filter_params)

    render json: { data: @jobs.as_json(user: current_user) }
  end

  # POST /jobs/:id/register_interest
  def register_interest
    authorize! :register_interest, @job

    CollaboratorStateService.new(@job, current_user).call(:interested)

    render json: { data: current_user.interested_in_jobs.as_json(user: current_user) }
  end

  # POST /jobs/:id/accept
  def accept
    authorize! :accept, @job

    CollaboratorStateService.new(@job, current_user).call(:accept)
    current_user.reload

    render json: { data: current_user.accepted_jobs.as_json(user: current_user) }
  end

  # POST /jobs/:id/complete
  def complete
    authorize! :complete, @job

    JobService.new(@job).complete

    render json: { data: @job.reload.as_json(user: current_user) }
  end

  # POST /jobs/:id/verify
  def verify
    authorize! :verify, @job

    Payment.complete(@job)
    JobService.new(@job).verify

    render json: { data: @job.reload.as_json(user: current_user) }
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def set_authenticated_job
    @job = current_user.jobs.find_by!(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def job_params
    params.permit(
      :title,
      :text,
      :proposed_start_at,
      :proposed_end_at,
      :allow_contact,
      per_diem: %i[min max],
      tag_list: []
    ).to_h
  end

  def collaborating_filter_params
    params.permit(
      :state,
      :limit
    ).to_h
  end
end
