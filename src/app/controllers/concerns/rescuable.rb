module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
end
