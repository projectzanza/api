Rails.application.config.to_prepare do
  Zanza::RocketChat.configure do |config|
    config.rocketchat_url = ENV['ROCKETCHAT_URL']
    config.admin_username = ENV['ROCKETCHAT_ADMIN_USER']
    config.admin_password = ENV['ROCKETCHAT_ADMIN_PASS']
    config.app_url = ENV['APP_URL']
    config.iframe = ENV['ROCKETCHAT_IFRAME']
    config.smtp_protocol = ENV['SES_PROTOCOL']
    config.smtp_host = ENV['SES_ADDRESS']
    config.smtp_port = ENV['SES_PORT']
    config.smtp_username = ENV['SES_USERNAME']
    config.smtp_password = ENV['SES_PASSWORD']
    config.from_email = ENV['SES_FROM']
  end
end

Zanza::RocketChat.update_settings if defined?(Rails::Server)
