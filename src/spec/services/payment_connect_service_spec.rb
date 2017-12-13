require 'rails_helper'
require_relative '../../app/exceptions/zanza/authorization_exception'

RSpec.describe PaymentConnectService, type: :service do
  describe 'stripe_login_url' do
    it 'should return a url' do
      user = create(:user)
      pcs = PaymentConnectService.new(user)
      expect(pcs.stripe_login_url).to match(/connect.stripe.com/)
    end
  end

  describe 'authorize' do
    before(:each) do
      @user = create(:user)
      @token = SecureRandom.hex
      @user.update(stripe_state_token: @token)
    end

    it 'should raise a Zanza::CallbackException if there are error parameters' do
      pcs = PaymentConnectService.new
      expect { pcs.authorize(error: 'BIGERROR', error_description: 'a description') }
        .to raise_error(Zanza::CallbackException)
    end

    it 'should raise an error if the user cannot be found' do
      pcs = PaymentConnectService.new
      expect { pcs.authorize(state: 'doesnotexist') }.to raise_error(Zanza::CallbackException)
    end

    it 'should raise an error if the oauth request errors out' do
      allow_any_instance_of(PaymentConnectService)
        .to receive(:post_oauth_request)
        .and_return(error: 'ERROR', error_description: 'description')
      pcs = PaymentConnectService.new
      expect { pcs.authorize(state: @user.stripe_state_token, code: '123') }.to raise_error(Zanza::CallbackException)
    end

    it 'should set the correct stripe tokens' do
      oauth_response = attributes_for(:stripe_oauth_response)
      allow_any_instance_of(PaymentConnectService).to receive(:post_oauth_request).and_return(oauth_response)
      pcs = PaymentConnectService.new
      pcs.authorize(state: @user.stripe_state_token, code: '123')
      expect(@user.reload.stripe_access_token).to eq oauth_response['access_token']
      expect(@user.stripe_scope).to eq oauth_response['scope']
      expect(@user.stripe_refresh_token).to eq oauth_response['refresh_token']
      expect(@user.stripe_user_id).to eq oauth_response['stripe_user_id']
      expect(@user.stripe_publishable_key).to eq oauth_response['stripe_publishable_key']
      expect(@user.stripe_state_token).to eq nil
      expect(@user.stripe_state_token_updated_at).to eq nil
    end
  end
end
