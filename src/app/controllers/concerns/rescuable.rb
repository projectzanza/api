module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_invalid
    rescue_from ActiveRecord::RecordNotSaved, with: :render_invalid
    rescue_from ActiveRecord::StatementInvalid, with: :render_invalid
    rescue_from Zanza::AuthorizationException, with: :render_unauthorized
    rescue_from Zanza::ForbiddenException, with: :render_forbidden
    rescue_from Zanza::PaymentException, with: :render_payment_unsuccessful
    rescue_from Zanza::PaymentPreConditionsNotMet, with: :render_payment_preconditions_not_met
  end

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_invalid(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def render_unauthorized(exception)
    render json: { error: exception.message }, status: :unauthorized
  end

  def render_forbidden(exception)
    render json: { error: exception.message }, status: :forbidden
  end

  def render_payment_unsuccessful
    render json: { error: 'There was a problem authorizing the payment, please try again' },
           status: :unprocessable_entity
  end

  def render_payment_preconditions_not_met(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
