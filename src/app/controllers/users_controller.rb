class UsersController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_user, only: [:show]
  before_action :set_authenticated_user, only: %i[update destroy]

  # GET /users/1
  def show
    @job = Job.find(params[:job_id]) if params[:job_id]
    render json: { data: @user.as_json(job: @job) }
  end

  # PATCH/PUT /users/1
  def update
    render json: { data: @user.reload } if @user.update!(user_params)
  end

  # GET /jobs/:job_id/users/match
  def match
    @job = Job.find(params[:job_id])
    users =
      if params[:filter]
        User.filter(params[:filter])
      else
        User.tagged_with(@job.tag_list)
      end
    render json: { data: users.as_json(job: @job) }
  end

  # GET /jobs/:job_id/users/collaborating
  def collaborating
    @job = Job.find(params[:job_id])
    @users = @job.find_collaborating_users(collaborating_filter_params)
    @users = @users.filter(params[:filter]) if params[:filter]
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
    @job = current_user.jobs.find(params[:job_id])
    @job.award_to_user(@user)

    render json: { data: @user.as_json(job: @job.reload) }
  end

  # POST /users/:id/reject
  def reject
    @user = User.find(params[:id])
    @job = current_user.jobs.find(params[:job_id])
    @job.reject_user(@user)

    render json: { data: @user.as_json(job: @job.reload) }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_authenticated_user
    fail Zanza::AuthorizationException if current_user.id != params[:id]
    @user = current_user
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.permit(:name, :email, :bio, per_diem: %i[min max], tag_list: []).to_h
  end

  def collaborating_filter_params
    params.permit(
      :state,
      :limit
    ).to_h
  end
end
