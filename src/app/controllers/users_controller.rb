class UsersController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_user, only: %i[show award invite reject certify decertify]
  before_action :set_authenticated_user, only: %i[update destroy]

  def index
    authorize! :list, User

    render json: { data: User.all }
  end

  # GET /users/1
  def show
    authorize! :read, User

    @job = Job.find(params[:job_id]) if params[:job_id]

    render json: { data: @user.as_json(job: @job) }
  end

  # PATCH/PUT /users/1
  def update
    authorize! :update, @user
    @user.update!(user_params)

    render json: { data: @user.reload }
  end

  # GET /jobs/:job_id/users/match
  def match
    authorize! :list, User

    @job = Job.find(params[:job_id])
    ums = UserMatchingService.new(@job, consultant_filter_params)
    ums.call

    render json: { data: ums.users.as_json(job: @job) }
  end

  # GET /jobs/:job_id/users/collaborating
  def collaborating
    authorize! :list, User

    @job = Job.find(params[:job_id])
    @users = @job.find_collaborating_users(collaborating_filter_params)
    @users = @users.filter(params[:filter]) if params[:filter]

    render json: { data: @users.as_json(job: @job) }
  end

  # POST /users/:user_id/invite
  # client to choose list of users who they would like to work on a job
  def invite
    authorize! :invite, @user

    @job = current_user.jobs.find(params[:job_id])
    CollaboratorStateService.new(@job, @user).call(:invite)

    render json: { data: @user.as_json(job: @job) }
  end

  #  POST /users/:id/award
  def award
    authorize! :award, @user

    @job = current_user.jobs.find(params[:job_id])
    CollaboratorStateService.new(@job, @user).call(:award)

    render json: { data: @user.as_json(job: @job.reload) }
  end

  # POST /users/:id/reject
  def reject
    authorize! :reject, @user

    @job = current_user.jobs.find(params[:job_id])
    CollaboratorStateService.new(@job, @user).call(:reject)

    render json: { data: @user.as_json(job: @job.reload) }
  end

  # POST /users/:id/certify
  def certify
    authorize! :certify, @user
    @user.update!(certified: true)
    render json: { data: @user.as_json }
  end

  # POST /users/:id/decertify
  def decertify
    authorize! :decertify, @user
    @user.update!(certified: false)
    render json: { data: @user.as_json }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_authenticated_user
    raise Zanza::AuthorizationException if current_user.id != params[:id]
    @user = current_user
  end

  def user_params
    params.permit(
      :name,
      :email,
      :headline,
      :summary,
      :country,
      :city,
      :onsite,
      :avatar_upload_url,
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

  def consultant_filter_params
    params.permit(
      :country,
      :city,
      :onsite,
      :name,
      :save
    ).to_h
  end
end
