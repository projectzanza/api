require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'post#token' do
    it 'should create a payment token' do
      token = attributes_for(:payment_provider_token)
      job = create(:job, user: @user)
      post :token,
           params: {
             token: token,
             job_id: job.id
           }

      expect(response).to have_http_status(:ok)
      expect(data['id']).to be_truthy
      expect(PaymentToken.find(data['id']).token['id']).to eq token[:id]
    end
  end
end
