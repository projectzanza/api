class UserCreateService
  def initialize(user)
    @user = user
  end

  def call
    chat_user = Zanza::RocketChat.create_user_unless_exists(@user)
    @user.chat_id = chat_user.id
    @user.save!
  end
end
