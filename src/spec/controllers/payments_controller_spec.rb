require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'post#token' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'should create add a new card to a user account' do
      token = StripeMock.generate_card_token
      job = create(:job, user: @user)
      post :token,
           params: {
             token: token,
             job_id: job.id
           }

      expect(response).to have_http_status(:ok)
      expect(response.body['success']).to be_truthy
      expect(@user.cards.length).to eq 1
    end

    it 'should associate a new card with a job' do
      token = StripeMock.generate_card_token
      job = create(:job, user: @user)
      post :token,
           params: {
             token: token,
             job_id: job.id
           }

      expect(job.reload.payment_card_id).to be_truthy
    end

    it 'should associate an existing card with a job' do
      token = StripeMock.generate_card_token
      card = @user.add_card(token)
      job = create(:job, user: @user)
      post :token,
           params: {
             card: card['id'],
             job_id: job.id
           }

      expect(job.reload.payment_card_id).to eq card['id']
    end

    it 'should return an error if the card specified does not exist' do
      token = StripeMock.generate_card_token
      @user.add_card(token)
      job = create(:job, user: @user)
      post :token,
           params: {
             card: 'non_existing_card_id',
             job_id: job.id
           }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#cards' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'should return an empty array if there are no cards saved' do
      get :cards

      expect(response).to have_http_status(:ok)
      expect(data).to eq []
    end

    it 'should list all saved cards belonging to the current user' do
      @user.add_card(StripeMock.generate_card_token)
      @user.add_card(StripeMock.generate_card_token)

      get :cards

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq 2
      expect(data.first.keys).to contain_exactly('exp_year', 'last4', 'brand', 'id')
    end
  end
end
