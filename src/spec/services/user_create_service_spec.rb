require 'rails_helper'

RSpec.describe UserCreateService, type: :service do
  describe 'call' do
    before(:each) do
      class_double('Zanza::RocketChat', create_user_unless_exists: double(id: '123')).as_stubbed_const
    end

    it 'should save the rocketchat user id to the user model' do
      user = create(:user)

      expect(user.chat_id).to be_falsey
      UserCreateService.new(user).call
      expect(user.chat_id).to be_truthy
    end
  end
end
