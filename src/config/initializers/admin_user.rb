@admin_username = ENV['ZANZA_ADMIN_USER']
@admin_password = ENV['ZANZA_ADMIN_PASS']
@admin_email = ENV['ZANZA_ADMIN_EMAIL']

def admin_user_properties_exist
  @admin_username && @admin_password && @admin_email
end

admin_user = User.find_by(email: @admin_email)
if admin_user_properties_exist && admin_user
  Rails.logger.info "A user with email #{@admin_email} already exists. Skipping create admin user"
elsif admin_user_properties_exist && !admin_user
  User.create(
    name: @admin_username,
    password: @admin_password,
    email: @admin_email,
    confirmed_at: Time.zone.now,
    admin: true
  )
  Rails.logger.info "Admin user with email address #{@admin_email} created"
else
  Rails.logger.info 'Admin user properties not specified in ENV vars. ADMIN_USER, ADMIN_PASS, admin_email'
end
