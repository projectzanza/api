require 'rails_helper'

RSpec.describe ScopesController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'post#create' do
    it 'should create a scope associated with a job' do
      job = create(:job, user: @user)
      scope_attrs = attributes_for(:scope)

      post :create,
           params: {
             job_id: job.id
           }.merge(scope_attrs)

      expect(response).to have_http_status(:ok)
      expect(data.first['title']).to eq(scope_attrs[:title])
      expect(data.first['description']).to eq(scope_attrs[:description])
    end

    it 'should return an error if the job does not belong to the user' do
      job = create(:job, user: create(:user))
      scope_attrs = attributes_for(:scope)

      post :create,
           params: {
             job_id: job.id
           }.merge(scope_attrs)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#index' do
    it 'should return all scopes belonging to a job' do
      job = create(:job, scope_count: 3)

      get :index,
          params: {
            job_id: job.id
          }

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq(3)
    end
  end
end
