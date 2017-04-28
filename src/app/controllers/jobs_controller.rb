class JobsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_job, only: [:show]
  before_action :set_authenticated_job, only: [:update, :destroy]

  # GET /jobs
  def index
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
    render json: { data: @job }
  end

  # POST /jobs
  def create
    @job = Job.new(job_params)
    Job.transaction do
      current_user.jobs << @job
      @job.save!
    end

    render json: { data: @job }, status: :created, location: @job
  end

  # PATCH/PUT /jobs/1
  def update
    render json: { data: @job } if @job.update!(job_params)
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
  end

  # GET /users/:user_id/jobs/match
  def match
    @user = User.find(params[:user_id])
    @jobs = Job.where(allow_contact: true)
               .where.not(user_id: params[:user_id])
               .tagged_with(@user.tag_list)
    render json: { data: @jobs }
  end

  # GET /users/:user_id/jobs/invited
  # a list a jobs the user_id is invited to
  def invited
    @user = User.find(params[:user_id])
    render json: { data: @user.invited_to_jobs }
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
      per_diem: [:min, :max],
      tag_list: []
    ).to_h
  end
end
