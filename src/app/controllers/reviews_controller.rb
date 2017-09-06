class ReviewsController < ApplicationController
  include Rescuable

  before_action :authenticate_user!

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
    @review = Review.new(review_params)
    current_user.written_reviews << @review
    authorize! :create, @review

    @review.save!
    render json: { data: @review }
  end

  private

  def review_params
    params.permit(
      :job_id,
      :subject_id,
      :ability,
      :communication,
      :speed,
      :overall
    ).to_h
  end

end
