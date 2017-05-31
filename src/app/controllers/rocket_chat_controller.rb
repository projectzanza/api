require 'rocketchat'

class RocketChatController < ApplicationController
  include Rescuable

  before_action :authenticate_user!, only: :login

  def login
    session = Zanza::RocketChat.login(current_user)
    raise Zanza::AuthorizationException, 'cannot log into chat' unless session
    current_user.update_attributes(
      rc_token: session.token.auth_token,
      rc_uid: session.token.user_id
    )

    render json: { data: { loginToken: current_user.rc_token, uid: current_user.rc_uid } }
  end
end
