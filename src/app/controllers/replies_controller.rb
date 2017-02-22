class RepliesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_reply, only: [:show]
  before_action :set_authenticated_reply, only: [:update, :destroy]

  # GET /replies
  def index
    raise ActiveRecord::RecordNotFound unless params[:job_id]
    job = Job.find(params[:job_id])

    render json: job.replies
  end

  # GET /replies/1
  def show
    render json: @reply
  end

  # POST /replies
  def create
    job = Job.find_by!(id: params[:job_id])
    reply = Reply.new(reply_params)

    Reply.transaction do
      job.replies << reply
      current_user.replies << reply
      reply.save!
    end

    render json: reply, status: :created, location: reply
  end

  # PATCH/PUT /replies/1
  def update
    render json: @reply if @reply.update!(reply_params)
  end

  # DELETE /replies/1
  def destroy
    @reply.destroy
  end

  private

  def set_reply
    @reply = Reply.find(params[:id])
  end

  def set_authenticated_reply
    @reply = current_user.replies.find_by!(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def reply_params
    params.permit(:text).to_h
  end
end
