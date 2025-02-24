class ReviewsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!
  before_action :set_authenticated_review, only: :update

  # GET /reviews
  def index
    authorize! :list, Review
    @reviews =
      if params[:user_id]
        User.find(params[:user_id]).reviews
      elsif params[:job_id]
        Job.find(params[:job_id]).reviews
      else
        []
      end

    render json: { data: @reviews }
  end

  # POST /reviews
  def create
    @review = Review.new(review_params.merge(user: current_user))
    authorize! :create, @review
    @review.save!

    render json: { data: @review }
  end

  def update
    authorize! :update, @review
    @review.update!(update_params)

    render json: { data: @review }
  end

  private

  def set_authenticated_review
    @review = current_user.written_reviews.find(params[:id])
  end

  def review_params
    params.permit(
      :job_id,
      :subject_id,
      :description,
      :ability,
      :communication,
      :speed,
      :overall
    ).to_h
  end

  def update_params
    params.permit(
      :description,
      :ability,
      :communication,
      :speed,
      :overall
    ).to_h
  end
end
