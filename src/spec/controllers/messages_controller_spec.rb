require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end

  describe 'get#index' do
    it 'should return all messages to a job' do
      3.times { create(:message, job: @job) }

      get :index,
          params: { job_id: @job.id }

      expect(json.length).to eq(3)
    end

    it 'should only return non-deleted messages' do
      messages = (0...3).collect { create(:message, job: @job) }
      messages.first.destroy

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
    it 'should return a single message' do
      message = create(:message, job: @job, user: @user)

      get :show,
          params: { id: message.id }

      expect(json['id']).to eq(message.id)
    end
  end

  describe 'post#create' do
    it 'should associate a message with a job and user' do
      message_attr = attributes_for(:message).merge(job_id: @job.id)

      post :create,
           params: message_attr

      expect(response).to have_http_status(:created)
      expect(json['job_id']).to eq(@job.id)
      expect(json['user_id']).to eq(@user.id)
      expect(json['text']).to eq(message_attr[:text])
    end

    it 'should require a job_id' do
      message_attr = attributes_for(:message)

      post :create,
           params: message_attr

      expect(response).to have_http_status(:not_found)
    end

    it 'should require a valid job_id' do
      message_attr = attributes_for(:message).merge(job_id: 'not-a-valid-job-id')

      post :create,
           params: message_attr

      expect(response).to have_http_status(:not_found)
    end

    it 'should require valid text' do
      message_attr = attributes_for(:message).merge(job_id: @job.id)
      message_attr.delete(:text)

      post :create,
           params: message_attr

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'patch#update' do
    it 'should be able to update a message' do
      message = create(:message, job: @job, user: @user)
      new_message_attr = attributes_for(:message).merge(id: message.id)

      patch :update,
            params: new_message_attr

      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(message.id)
      expect(json['text']).to eq(new_message_attr[:text])
    end

    it 'should not be able to update another users message' do
      message = create(:message, job: @job, user: @user)
      new_message_attr = attributes_for(:message).merge(id: message.id)

      login_user

      patch :update,
            params: new_message_attr

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'delete#destroy' do
    it 'should be able to soft delete a users own message' do
      message = create(:message, job: @job, user: @user)

      delete :destroy,
             params: { id: message.id }

      expect(response).to have_http_status(:no_content)
      expect { Message.find(message.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Message.only_deleted.find(message.id)).to be_truthy
    end

    it 'should not be able to delete another users message' do
      message = create(:message, job: @job, user: @user)
      login_user
      delete :destroy,
             params: { id: message.id }

      expect(response).to have_http_status(:not_found)
    end
  end
end
