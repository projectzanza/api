module Helpers
  module Controllers
    def json
      JSON.parse(response.body)
    end

    def data
      JSON.parse(response.body)['data']
    end

    def login_user(user = nil)
      request.env['devise.mapping'] = Devise.mappings[:user]
      @user = user || create(:user)
      @user.confirm
      sign_in(@user)
      request.headers.merge!(@user.create_new_auth_token)
    end
    alias login_another_user login_user
  end
end
