class PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_authenticated_position, only: %i[show update destroy]

  # GET /positions
  def index
    positions = User.find(params[:user_id]).positions.all

    render json: { data: positions }
  end

  # POST /positions
  def create
    position = Position.new(position_params)
    current_user.positions << position
    position.save!

    render json: { data: position }
  end

  # PATCH/PUT /positions/1
  def update
    @position.update!(position_params)

    render json: { data: @position }
  end

  # DELETE /positions/1
  def destroy
    @position.destroy
    render json: { success: true }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_authenticated_position
    @position = current_user.positions.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def position_params
    params.permit(
      :title,
      :summary,
      :company,
      :start_at,
      :end_at
    ).to_h
  end
end
