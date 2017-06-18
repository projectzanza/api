Zanza::RocketChat.configure do |config|
  config.rocketchat_url = ENV['ROCKETCHAT_URL']
  config.admin_username = ENV['ROCKETCHAT_ADMIN_USER']
  config.admin_password = ENV['ROCKETCHAT_ADMIN_PASS']
  config.app_url = ENV['APP_URL']
end
