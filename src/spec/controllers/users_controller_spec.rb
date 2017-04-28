require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end

  # TODO: tests for /jobs/:job_id/users/match
  # should not return current user in match
  # should not return invited users in match

  describe 'post#invite' do
    it 'should mark the user as invited to a job' do
      consultant = create(:user)

      post :invite,
           params: {
             id: consultant.id,
             job_id: @job.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(consultant.id)
      expect(@job.invited_users).to include(consultant)
    end

    it 'should return an error if the owner is not the user inviting consultants to a job' do
      consultant = create(:user)

      login_user

      post :invite,
           params: {
             id: consultant.id,
             job_id: @job.id
           }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#invited' do
    it 'should return all users invited to a job' do
      consultant = create(:user)
      @job.invited_users << consultant

      get :invited,
          params: {
            job_id: @job.id
          }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(consultant.id)
    end
  end

  describe 'get#interested' do
    it 'should return all users who registered interest in a job' do
      users = (0...3).collect { create(:user) }
      @job.interested_users << users

      get :interested,
          params: {
            job_id: @job.id
          }

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq(3)
    end
  end
end
