require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'get#index' do
    it 'should return a list of all jobs' do
      3.times { create(:job, user: @user) }
      get :index
      expect(data.length).to eq 3
    end

    it 'should only return non-deleted jobs' do
      jobs = (0...3).collect { create(:job, user: @user) }
      jobs[0].destroy
      get :index
      expect(data.length).to eq 2
    end

    it 'should return a list of jobs created by a user when user_id is supplied' do
      3.times { create(:job, user: @user) }
      login_another_user
      create(:job, user: @user)
      get :index,
          params: { user_id: @user.id }
      expect(data.length).to eq 1
    end
  end

  describe 'get#show' do
    it 'should return a single job' do
      job = create(:job, user: @user)

      get :show,
          params: { id: job.id }

      expect(data['id']).to eq job.id
    end
  end

  describe 'post#create' do
    it 'should create a job' do
      job_attr = attributes_for(:job)

      post :create,
           params: job_attr

      expect(response).to have_http_status(:created)
      expect(data['id']).to be_truthy
      expect(data['title']).to eq job_attr[:title]
      expect(data['text']).to eq job_attr[:text]
      expect(data['user_id']).to eq @user.id
      expect(data['tag_list']).to eq job_attr[:tag_list]
      expect(data['per_diem']['min']).to eq job_attr[:per_diem][:min].to_s
      expect(data['per_diem']['max']).to eq job_attr[:per_diem][:max].to_s
      expect(data['closed_at']).to be_falsey
    end

    it 'should require a title to be created' do
      job_attr = attributes_for(:job)
      job_attr.delete(:title)

      post :create,
           params: job_attr

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'patch#update' do
    it 'should update the job details belonging to a user' do
      job = create(:job, user: @user)
      new_job_attr = attributes_for(:job)

      patch :update,
            params: new_job_attr.merge(id: job.id)

      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq(job.id)
      expect(data['title']).to eq new_job_attr[:title]
      expect(data['text']).to eq new_job_attr[:text]
      expect(data['tag_list']).to eq new_job_attr[:tag_list]
      expect(data['per_diem']['min']).to eq new_job_attr[:per_diem][:min].to_s
      expect(data['per_diem']['max']).to eq new_job_attr[:per_diem][:max].to_s
    end

    it 'should return an error if trying to update another users job' do
      job = create(:job, user: @user)
      login_another_user
      new_job_attr = attributes_for(:job)

      patch :update,
            params: new_job_attr.merge(id: job.id)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'delete#destroy' do
    it 'should soft delete the job' do
      job = create(:job, user: @user)

      delete :destroy,
             params: { id: job.id }

      expect { Job.find(job.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Job.only_deleted.find(job.id)).to be_truthy
    end

    it 'should not delete another users job' do
      job = create(:job, user: @user)

      login_user

      delete :destroy,
             params: { id: job.id }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#match' do
    it 'should return jobs which match the users' do
      tag_list = %w(tag1 tag2)
      3.times { create(:job, tag_list: tag_list, user: @user) }

      login_user
      @user.update_attributes(tag_list: tag_list)

      get :match,
          params: { user_id: @user.id }

      expect(data.length).to eq 3
    end

    it 'should only return jobs where job creator has set allow_contact to true' do
      tag_list = %w(tag1 tag2)
      3.times { create(:job, tag_list: tag_list, user: @user) }
      2.times { create(:job, tag_list: tag_list, allow_contact: false, user: @user) }

      login_user
      @user.update_attributes(tag_list: tag_list)

      get :match,
          params: { user_id: @user.id }

      expect(data.length).to eq 3
    end

    it 'should not return jobs which the user is the creator of' do
      tag_list = %w(tag1 tag2)
      3.times { create(:job, tag_list: tag_list, user: @user) }

      login_user

      2.times { create(:job, tag_list: tag_list, user: @user) }
      @user.update_attributes(tag_list: tag_list)

      get :match,
          params: { user_id: @user.id }

      expect(data.length).to eq 3
    end

    it 'should return 404 if an invalid user_id is supplied' do
      get :match,
          params: { user_id: 'not-a-valid-user-id' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#invited' do
    it 'should return a list of jobs a user is invited to' do
      jobs = (0...3).collect { create(:job, user: @user) }

      @user.invited_to_jobs << jobs

      get :invited,
          params: { user_id: @user.id }

      expect(data.length).to eq(3)
    end
  end

  describe 'post#register_interest' do
    it 'should register a user as interested in a job' do
      job = create(:job, user: build(:user))

      post :register_interest,
           params: { id: job.id }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(job.id)
    end
  end

  describe 'get#interested' do
    it 'should list all jobs a user is interested in' do
      jobs = (0...3).collect { create(:job, user: build(:user)) }
      @user.interested_in_jobs << jobs

      get :interested

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq(3)
    end
  end
end
