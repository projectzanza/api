require 'rails_helper'

RSpec.describe EstimatesController, type: :controller do
  describe 'post#estimate' do
    it 'sets an estimate for a user on a job' do
      job = create(:job)
      consultant = create(:user)
      estimate = attributes_for(:estimate)

      post :create,
           params: {
             job_id: job.id,
             user_id: consultant.id
           }.merge(estimate)

      expect(response).to have_http_status(:ok)
      expect(data['job_id']).to eq(job.id)
      expect(data['user_id']).to eq(consultant.id)
      expect(data['days']).to eq(estimate[:days])
      expect(Time.parse(data['start_at'])).to eq(estimate[:start_at])
      expect(Time.parse(data['end_at'])).to eq(estimate[:end_at])
      expect(data['per_diem']).to match(/^\$\d+,?\d*?\.\d+/)
      expect(data['total']).to match(/^\$\d+,?\d*?\.\d+/)
    end

    it 'automatically sets the user as interested in the job' do
      job = create(:job)
      estimate = attributes_for(:estimate)
      consultant = create(:user)

      post :create,
           params: {
             job_id: job.id,
             user_id: consultant.id
           }.merge(estimate)

      expect(job.interested_users).to include(consultant)
    end

    it 'can only create one estimate per user/job combination' do
      job = create(:job)
      consultant = create(:user)
      estimate = attributes_for(:estimate)

      post :create,
           params: {
             job_id: job.id,
             user_id: consultant.id
           }.merge(estimate)

      estimate2 = attributes_for(:estimate)
      post :create,
           params: {
             job_id: job.id,
             user_id: consultant.id
           }.merge(estimate2)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(consultant.estimates.count).to eq(1)
    end
  end

  describe 'put#estimate' do
    it 'updates the estimate with new parameters' do
      job = create(:job)
      consultant = create(:user)
      estimate = attributes_for(:estimate)

      post :create,
           params: {
             job_id: job.id,
             user_id: consultant.id
           }.merge(estimate)

      expect(data['days']).to eq(estimate[:days])
      estimate_id = data['id']
      new_estimate = estimate.merge(days: estimate[:days] + 1)

      put :update,
          params: {
            id: estimate_id
          }.merge(new_estimate)

      expect(data['days']).to eq(new_estimate[:days])
    end
  end
end
