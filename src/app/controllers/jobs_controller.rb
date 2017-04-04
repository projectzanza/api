class JobsController < ApplicationController
  include Rescuable
  include Taggable

  before_action :authenticate_user!
  before_action :set_job, only: [:show]
  before_action :set_authenticated_job, only: [:update, :destroy]
  before_action :set_authenticated_item, only: [:add_tag, :remove_tag]

  # GET /jobs
  def index
    @jobs = Job.all

    render json: @jobs
  end

  # GET /jobs/1
  def show
    render json: @job
  end

  # POST /jobs
  def create
    @job = Job.new(job_params)
    Job.transaction do
      current_user.jobs << @job
      @job.save!
    end

    render json: @job, status: :created, location: @job
  end

  # PATCH/PUT /jobs/1
  def update
    render json: @job.to_json if @job.update!(job_params)
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def set_authenticated_job
    @job = current_user.jobs.find_by!(id: params[:id])
  end

  def set_authenticated_item
    @item = set_authenticated_job
  end

  # Only allow a trusted parameter "white list" through.
  def job_params
    params.permit(:title, :text, tag_list: []).to_h
  end
end
