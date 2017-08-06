require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'post#token' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'should create a payment token' do
      token = StripeMock.generate_card_token
      job = create(:job, user: @user)
      post :token,
           params: {
             token: token,
             job_id: job.id
           }

      expect(response).to have_http_status(:ok)
      expect(response.body['success']).to be_truthy
    end
  end
end
