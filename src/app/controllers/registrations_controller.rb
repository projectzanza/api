class RegistrationsController < DeviseTokenAuth::RegistrationsController
  def create
    super do |resource|
      Rails.logger.info 'overriding devise create user method'
      UserCreateService.new(resource).call
    end
  end
end
