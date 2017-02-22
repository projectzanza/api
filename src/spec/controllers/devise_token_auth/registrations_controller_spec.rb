require 'rails_helper'

RSpec.describe DeviseTokenAuth::RegistrationsController, type: :controller do
  describe 'register new user' do
    it 'should add a user to the db' do
      post :create,
           params: attributes_for(:user)

      expect(response).to have_http_status(200)
      expect(User.all.count).to eq 1
    end

    it 'should send an email for confirmation' do
      user = attributes_for(:user)

      post :create,
           params: user

      expect(ActionMailer::Base.deliveries.last.to).to match_array(user[:email])
    end
  end
end
