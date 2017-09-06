require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  before(:each) do
    @user = create(:user)
    @job = create(:job, user: @user)
    @consultant = create(:user)
    login_user(@user)
  end

  describe 'post#create' do
    before(:each) do
      @job.add_collaborator(:award, user: @consultant)
      @job.update_collaborator(:accept, user: @consultant)
    end

    it 'should associate a review with a user and a job' do
      @job.verify

      post :create,
           params: attributes_for(:review).merge(
             job_id: @job.id,
             subject_id: @consultant.id
           )

      expect(response).to have_http_status(:ok)
      expect(@consultant.reviews.count).to eq 1
      expect(@job.reviews.count).to eq 1
      expect(@user.written_reviews.count).to eq 1
    end

    it 'should allow the consultant to write a review of the client' do
      @job.verify
      login_user(@consultant)

      post :create,
           params: attributes_for(:review).merge(
             job_id: @job.id,
             subject_id: @user.id
           )

      expect(response).to have_http_status(:ok)
      expect(@consultant.reviews.count).to eq 1
      expect(@job.reviews.count).to eq 1
      expect(@user.written_reviews.count).to eq 1
    end

    it 'should not allow a review to be written until the job has been verified' do
      @job.complete

      post :create,
           params: attributes_for(:review).merge(
             job_id: @job.id,
             subject_id: @consultant.id
           )

      expect(response).to have_http_status(:unauthorized)
    end

    it 'should only allow the client or consultant to write a review in a job' do
      login_user

      post :create,
           params: attributes_for(:review).merge(
             job_id: @job.id,
             subject_id: @consultant.id
           )

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'get#index' do
    it 'should return all the reviews written about a user when user_id is defined' do
      create(:review, user: @user, subject: @consultant, job: @job)
      new_user = create(:user)
      new_job = create(:job, user: new_user)
      create(:review, user: new_user, subject: @consultant, job: new_job)

      get :index,
          params: { user_id: @consultant.id }

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq 2
    end

    it 'should return all reviews written about a job when job_id is defined' do
      create(:review, user: @user, subject: @consultant, job: @job)
      create(:review, user: @consultant, subject: @user, job: @job)

      get :index,
          params: { job_id: @job.id }

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq 2

    end
  end

end
