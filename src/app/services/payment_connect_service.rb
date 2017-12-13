class PaymentConnectService
  attr_accessor :user

  def initialize(user = nil)
    @user = user
  end

  def stripe_login_url
    @user.update(stripe_state_token: SecureRandom.hex)

    "#{Rails.configuration.x.stripe.url}/oauth/authorize"\
           '?response_type=code'\
           '&scope=read_only'\
           "&client_id=#{Rails.configuration.x.stripe.client_id}"\
           "&state=#{@user.stripe_state_token}"
  end

  def authorize(params)
    raise Zanza::CallbackException, params[:error_description] if params[:error]

    @user = User.find_by_stripe_state_token(params[:state])
    raise Zanza::CallbackException, 'User account could not be found' unless @user
    json = post_oauth_request(params[:code])
    raise Zanza::CallbackException, json[:error_description] if json[:error]

    @user.update(
      stripe_state_token: nil,
      stripe_state_token_updated_at: nil,
      stripe_access_token: json['access_token'],
      stripe_scope: json['scope'],
      stripe_refresh_token: json['refresh_token'],
      stripe_user_id: json['stripe_user_id'],
      stripe_publishable_key: json['stripe_publishable_key']
    )
  end

  def post_oauth_request(code)
    uri = URI.parse("#{Rails.configuration.x.stripe.url}/oauth/token")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    post = Net::HTTP::Post.new(uri.path)
    post.set_form_data(
      client_secret: Rails.configuration.x.stripe.api_key,
      grant_type: 'authorization_code',
      code: code
    )
    res = https.request(post)
    raise Zanza::CallbackException, 'There was an error connecting to your stripe account' if res.code.to_i >= 300

    JSON.parse(res.body)
  end
end
