require 'rails_helper'

RSpec.describe EstimatesController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end

  describe 'post#estimate' do
    it 'sets an estimate for a user on a job' do
      estimate = attributes_for(:estimate, job_id: @job.id)

      post :create,
           params: estimate

      expect(response).to have_http_status(:ok)
      expect(data['job_id']).to eq(@job.id)
      expect(data['user_id']).to eq(@user.id)
      expect(data['days']).to eq(estimate[:days])
      expect(Time.parse(data['start_at'])).to eq(estimate[:start_at])
      expect(Time.parse(data['end_at'])).to eq(estimate[:end_at])
      expect(data['per_diem']).to match(/^\$\d+,?\d*?\.\d+/)
      expect(data['total']).to match(/^\$\d+,?\d*?\.\d+/)
    end

    it 'automatically sets the user as interested in the job' do
      estimate = attributes_for(:estimate, job_id: @job.id)

      post :create,
           params: estimate

      expect(@job.interested_users).to include(@user)
    end

    it 'can create multiple estimates per user/job combination' do
      estimate = attributes_for(:estimate, job_id: @job.id)

      post :create,
           params: estimate

      estimate2 = attributes_for(:estimate, job_id: @job.id)
      post :create,
           params: estimate2

      expect(response).to have_http_status(:ok)
      expect(@user.reload.estimates.count).to eq(2)
    end
  end

  describe 'put#estimate' do
    it 'updates the estimate with new parameters' do
      estimate = attributes_for(:estimate, job_id: @job.id)

      post :create,
           params: estimate

      expect(data['days']).to eq(estimate[:days])
      estimate_id = data['id']
      new_estimate = estimate.merge(days: estimate[:days] + 1)

      put :update,
          params: new_estimate.merge(id: estimate_id)

      expect(response).to have_http_status(:ok)
      expect(data['days']).to eq(new_estimate[:days])
    end

    it 'cannot update an accepted estimate' do
      estimate = attributes_for(:estimate, job_id: @job.id)

      post :create,
           params: estimate

      estimate_id = data['id']
      Estimate.find(estimate_id).accept

      new_estimate = estimate.merge(days: estimate[:days] + 1)
      put :update,
          params: new_estimate.merge(id: estimate_id)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'delete#estimate' do
    it 'should respond success if user is allowed to delete the estimate' do
      estimate = create(:estimate, job: create(:job), user: @user)

      delete :destroy,
             params: {
               id: estimate.id
             }

      expect(response).to have_http_status(:ok)
      expect(estimate.reload.deleted_at).to be_truthy
    end

    it 'should respond with a 404 if user is not authorized to delete the estimate' do
      estimate = create(:estimate, job: create(:job), user: create(:user))

      delete :destroy,
             params: {
               id: estimate.id
             }

      expect(response).to have_http_status(:not_found)
      expect(estimate.deleted_at).to be_falsey
    end
  end

  describe 'accept#estimate' do
    before(:each) do
      @estimate = create(:estimate, job: @job, user: create(:user))
    end

    it 'should respond with the accepted estimate if successful' do
      post :accept,
           params: {
             id: @estimate.id
           }

      expect(response).to have_http_status(:ok)
      estimate = data.find { |est| est['id'] == @estimate.id }
      expect(estimate['state']).to eq 'accepted'
    end

    it 'should respond with an error if the estimate does not belong to the users jobs' do
      login_user

      post :accept,
           params: {
             id: @estimate.id
           }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'reject#estimate' do
    before(:each) do
      @estimate = create(:estimate, job: @job, user: create(:user))
      @estimate.accept
    end

    it 'should respond with the rejected estimate if successful' do
      post :reject,
           params: {
             id: @estimate.id
           }

      expect(response).to have_http_status(:ok)
      estimate = data.find { |est| est['id'] == @estimate.id }
      expect(estimate['state']).to eq 'rejected'
    end

    it 'should respond with an error if the estimate does not belong to the users jobs' do
      login_user

      post :reject,
           params: {
             id: @estimate.id
           }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
