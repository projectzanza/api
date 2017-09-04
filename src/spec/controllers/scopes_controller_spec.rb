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

  describe 'put#update' do
    it 'should update the scope if the user is allowed to' do
      job = create(:job, scope_count: 1, user: @user)
      scope = attributes_for(:scope)

      put :update,
          params: scope.merge(id: job.scopes.first.id)

      expect(response).to have_http_status(:ok)
      expect(data['title']).to eq(scope[:title])
    end

    it 'should not allow update if the user does not own the job' do
      job = create(:job, scope_count: 1, user: create(:user))
      scope = attributes_for(:scope)

      put :update,
          params: scope.merge(id: job.scopes.first.id)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#complete' do
    before(:each) do
      @job = create(:job, scope_count: 1, user: @user)
      @scope = @job.scopes.first
    end

    it 'should let the job owner complete a scope' do
      post :complete,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('completed')
    end

    it 'should let the awarded consultant complete a scope' do
      consultant = create(:user)
      @job.update_collaborator(:award, user: consultant)

      login_user(consultant)

      post :complete,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('completed')
    end

    it 'should not let other users complete the scope' do
      consultant = create(:user)
      @job.update_collaborator(:award, user: consultant)

      login_user

      post :complete,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#verify' do
    before(:each) do
      @job = create(:job, scope_count: 1, user: @user)
      @scope = @job.scopes.first
    end

    it 'should let the job owner verify the scope' do
      post :verify,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('verified')
    end

    it 'should not let the awarded user verify the scope' do
      consultant = create(:user)
      @job.update_collaborator(:award, user: consultant)

      login_user(consultant)

      post :verify,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#reject' do
    before(:each) do
      @job = create(:job, scope_count: 1, user: @user)
      @scope = @job.scopes.first
    end

    it 'should let the job owner reject a completed scope' do
      post :complete,
           params: {
             id: @scope.id
           }

      post :reject,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('rejected')
    end

    it 'should let the job owner reject a verified scope' do
      post :verify,
           params: {
             id: @scope.id
           }

      post :reject,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('rejected')
    end

    it 'should not the let the awarded consultant reject a scope' do
      consultant = create(:user)
      @job.update_collaborator(:award, user: consultant)

      post :complete,
           params: {
             id: @scope.id
           }

      login_user(consultant)

      post :reject,
           params: {
             id: @scope.id
           }

      expect(response).to have_http_status(:ok)
      expect(data.first['state']).to eq('rejected')
    end
  end

  describe 'delete#destroy' do
    before(:each) do
      @job = create(:job, scope_count: 2, user: @user)
      @scope = @job.scopes.first
    end

    it 'should allow the job owner to delete a scope' do
      delete :destroy,
             params: { id: @scope.id }

      expect(response).to have_http_status(:ok)

      expect(@job.reload.scopes.count).to eq(1)
    end

    it 'should not allow non owners to delete a scope' do
      consultant = create(:user)

      login_user(consultant)
      delete :destroy,
             params: { id: @scope.id }

      expect(response).to have_http_status(:unauthorized)
      expect(@job.reload.scopes.count).to eq(2)
    end
  end
end
