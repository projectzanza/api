require 'rails_helper'

RSpec.describe RepliesController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end

  describe 'get#index' do
    it 'should return all replies to a job' do
      3.times { create(:reply, job: @job) }

      get :index,
          params: { job_id: @job.id }

      expect(json.length).to eq(3)
    end

    it 'should only return non-deleted replies' do
      replies = (0...3).collect { create(:reply, job: @job) }
      replies.first.destroy

      get :index,
          params: { job_id: @job.id }

      expect(json.length).to eq(2)
    end

    it 'should return an error if no job_id is specified' do
      get :index

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'get#show' do
    it 'should return a single reply' do
      reply = create(:reply, job: @job, user: @user)

      get :show,
          params: { id: reply.id }

      expect(json['id']).to eq(reply.id)
    end
  end

  describe 'post#create' do
    it 'should associate a reply with a job and user' do
      reply_attr = attributes_for(:reply).merge(job_id: @job.id)

      post :create,
           params: reply_attr

      expect(response).to have_http_status(:created)
      expect(json['job_id']).to eq(@job.id)
      expect(json['user_id']).to eq(@user.id)
      expect(json['text']).to eq(reply_attr[:text])
    end

    it 'should require a job_id' do
      reply_attr = attributes_for(:reply)

      post :create,
           params: reply_attr

      expect(response).to have_http_status(:not_found)
    end

    it 'should require a valid job_id' do
      reply_attr = attributes_for(:reply).merge(job_id: 'not-a-valid-job-id')

      post :create,
           params: reply_attr

      expect(response).to have_http_status(:not_found)
    end

    it 'should require valid text' do
      reply_attr = attributes_for(:reply).merge(job_id: @job.id)
      reply_attr.delete(:text)

      post :create,
           params: reply_attr

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'patch#update' do
    it 'should be able to update a reply' do
      reply = create(:reply, job: @job, user: @user)
      new_reply_attr = attributes_for(:reply).merge(id: reply.id)

      patch :update,
            params: new_reply_attr

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(reply.id)
      expect(json['text']).to eq(new_reply_attr[:text])
    end

    it 'should not be able to update another users reply' do
      reply = create(:reply, job: @job, user: @user)
      new_reply_attr = attributes_for(:reply).merge(id: reply.id)

      login_user

      patch :update,
            params: new_reply_attr

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'delete#destroy' do
    it 'should be able to soft delete a users own reply' do
      reply = create(:reply, job: @job, user: @user)

      delete :destroy,
             params: { id: reply.id }

      expect(response).to have_http_status(:no_content)
      expect { Reply.find(reply.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Reply.only_deleted.find(reply.id)).to be_truthy
    end

    it 'should not be able to delete another users reply' do
      reply = create(:reply, job: @job, user: @user)
      login_user
      delete :destroy,
             params: { id: reply.id }

      expect(response).to have_http_status(:not_found)
    end
  end
end
