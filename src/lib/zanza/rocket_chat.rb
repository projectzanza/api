require 'logger'

module Zanza
  module RocketChat
    class << self
      attr_accessor :rocketchat_url, :admin_username, :admin_password, :app_url, :iframe,
                    :smtp_protocol, :smtp_host, :smtp_port, :smtp_username, :smtp_password, :from_email
    end

    def self.settings
      {
        'Accounts_iframe_enabled' => @iframe,
        'Iframe_Integration_send_enable' => @iframe,
        'Iframe_Integration_send_target_origin' => @iframe && @app_url,
        'Iframe_Integration_receive_enable' => @iframe,
        'Iframe_Integration_receive_origin' => @iframe && @app_url,
        'SMTP_Protocol' => @smtp_protocol,
        'SMTP_Host' => @smtp_host,
        'SMTP_Port' => @smtp_port,
        'SMTP_Username' => @smtp_username,
        'SMTP_Password' => @smtp_password,
        'From_Email' => @from_email
      }
    end

    def self.configure
      yield self
    end

    def self.update_settings
      Rails.logger.info 'Launching thread to update rocket chat server settings'
      Thread.new do
        update_settings_thread
      end
    end

    def self.update_settings_thread
      settings.each_pair do |key, value|
        admin_session.settings[key] = value
      end
      Rails.logger.info "RocketChat server settings set to: \n #{settings}"
    rescue SocketError => se
      Rails.logger.error "Error connecting to RocketChat \n #{se} \n Trying again in 10 seconds"
      sleep 10
      retry
    end

    def self.server
      @serv = ::RocketChat::Server.new(rocketchat_url)
    end

    def self.admin_session
      @admin_sess ||= server.login(admin_username, admin_password)
    end

    # rubocop can't decide on GuardClause, reports an error either way
    def self.create_user_unless_exists(user)
      chat_user = admin_session.users.info(username: user.nickname)
      unless chat_user
        chat_user = admin_session.users.create(
          user.nickname,
          user.email,
          user.name,
          user.rc_password,
          active: true,
          send_welcome_email: false
        )
      end
      chat_user
    end
    # rubocop:enable Style/GuardClause

    def self.login(user)
      create_user_unless_exists(user)
      server.login(user.nickname, user.rc_password)
    rescue ::RocketChat::StatusError => e
      Rails.logger.error "Error logging in user to rocketchat #{e}"
      nil
    end

    def self.chat_title(job)
      title = job.title.tr(' ', '-')
      "#{title.gsub(/[^0-9A-Za-z\-]/, '')[0..20]}-#{job.id[0..5]}"
    end
  end
end
