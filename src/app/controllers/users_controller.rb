class UsersController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_user, only: [:show]
  before_action :set_authenticated_user, only: [:update, :destroy]

  # GET /users
  def index
    @users = User.all
    render json: { data: @users }
  end

  # GET /users/1
  def show
    @job = Job.find(params[:job_id]) if params[:job_id]
    render json: { data: @user.as_json(job: @job) }
  end

  # PATCH/PUT /users/1
  def update
    render json: { data: @user } if @user.update!(user_params)
  end

  # GET /jobs/:job_id/users/match
  def match
    @job = Job.find(params[:job_id])
    render json: { data: User.tagged_with(@job.tag_list).as_json(job: @job) }
  end

  # GET /jobs/:job_id/users/collaborating
  def collaborating
    @job = Job.find(params[:job_id])
    @users = @job.find_collaborating_users(collaborating_filter_params)
    render json: { data: @users.as_json(job: @job) }
  end

  # POST /users/:user_id/invite
  # client to choose list of users who they would like to work on a job
  def invite
    @user = User.find(params[:id])
    @job = current_user.jobs.find(params[:job_id])
    @job.invite_users(@user)
    @job.reload

    render json: { data: @job.invited_users.as_json(job: @job) }
  end

  #  POST /users/:id/award
  def award
    @user = User.find(params[:id])
    @job = Job.find(params[:job_id])
    @job.award_to_user(@user)
    @job.reload

    render json: { data: @user.as_json(job: @job) }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_authenticated_user
    raise ActiveRecord::RecordNotFound unless current_user
    @user = current_user
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.permit(:name, :bio, per_diem: [:min, :max], tag_list: []).to_h
  end

  def collaborating_filter_params
    params.permit(
      :filter,
      :limit
    ).to_h
  end
end
