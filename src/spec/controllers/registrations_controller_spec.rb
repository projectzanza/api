require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'register new user' do
    it 'should add a user to the db' do
      user = attributes_for(:user)

      rc_double = double('Zanza::RocketChat')
      allow(rc_double).to receive(:create_user_unless_exists).and_return(double(id: '123'))

      post :create,
           params: user

      expect(response).to have_http_status(:ok)
      expect(User.all.count).to eq 1
    end

    it 'should send an email for confirmation' do
      user = attributes_for(:user)

      rc_double = double('Zanza::RocketChat')
      allow(rc_double).to receive(:create_user_unless_exists).and_return(double(id: '123'))

      post :create,
           params: user

      expect(ActionMailer::Base.deliveries.last.to).to match_array(user[:email])
    end
  end
end
