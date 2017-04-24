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
    render json: { data: @user }
  end

  # PATCH/PUT /users/1
  def update
    render json: { data: @user } if @user.update!(user_params)
  end

  # GET /jobs/:job_id/users/match
  def match
    @job = Job.find(params[:job_id])
    render json: { data: User.tagged_with(@job.tag_list) }
  end

  # PUT /users/:user_id/invite
  # client to choose list of users who they would like to work on a job
  def invite
    @user = User.find(params[:id])
    @job = current_user.jobs.find(params[:job_id])
    @job.invited_users << @user

    render json: { data: @job.invited_users }
  end

  # GET /users/invited
  # list all users chosen for a job
  def invited
    @job = Job.find(params[:job_id])
    render json: { data: @job.invited_users }
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
end
