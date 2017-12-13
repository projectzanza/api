class OmniauthController < ApplicationController
  include Rescuable

  before_action :authenticate_user!, only: :stripe

  def stripe
    url = PaymentConnectService.new(current_user).stripe_login_url
    render json: { link: url }
  end

  def stripe_callback
    pcs = PaymentConnectService.new
    pcs.authorize(params)

    redirect_to ENV['APP_URL'] + "/user/#{pcs.user.id}"
  end
end
