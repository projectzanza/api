class MessagesController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_message, only: [:show]
  before_action :set_authenticated_message, only: [:update, :destroy]

  # GET /messages
  def index
    raise ActiveRecord::RecordNotFound unless params[:job_id]
    job = Job.find(params[:job_id])

    render json: job.messages
  end

  # GET /messages/1
  def show
    render json: @message
  end

  # POST /messages
  def create
    job = Job.find_by!(id: params[:job_id])
    message = Message.new(message_params.merge(user: current_user))

    Message.transaction do
      job.messages << message
      current_user.messages << message
      message.save!
    end

    render json: message, status: :created, location: message
  end

  # PATCH/PUT /messages/1
  def update
    render json: @message if @message.update!(message_params)
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def set_authenticated_message
    @message = current_user.messages.find_by!(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def message_params
    params.permit(:text).to_h
  end
end
