require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'post#choose' do
    before(:each) do
      @job = create(:job, user: @user)
    end

    it 'should mark the user as selected for a job' do
      consultant = create(:user)

      post :choose,
           params: {
             id: consultant.id,
             job_id: @job.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(consultant.id)
      expect(@job.selected_users).to include(consultant)
    end

    it 'should return an error if the owner is not the user selecting consultants for a job' do
      consultant = create(:user)

      login_user

      post :choose,
           params: {
             id: consultant.id,
             job_id: @job.id
           }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#chosen' do
    before(:each) do
      @job = create(:job, user: @user)
    end

    it 'should return all users chosen for a job' do
      consultant = create(:user)
      @job.selected_users << consultant

      get :chosen,
          params: {
            job_id: @job.id
          }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(consultant.id)
    end
  end
end
