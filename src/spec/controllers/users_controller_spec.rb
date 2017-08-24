require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end


  describe 'put#update' do
    it 'should return updated user information is successful' do
      user = attributes_for(:user)
      expect(user['email']).not_to eq(@user.name)

      put :update,
          params: user.merge(id: @user.id)

      expect(response).to have_http_status(:ok)
      expect(data['email']).to eq user[:email]
    end

    it 'should only allow a user to update their own information' do
      user = attributes_for(:user)
      another_user = create(:user)

      put :update,
          params: user.merge(id: another_user.id)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # TODO: tests for /jobs/:job_id/users/match (without filter)
  # should not return current user in match
  # should not return invited users in match

  describe 'get#match' do
    it 'should filter on email address with the filter parameter' do
      job = create(:job)
      3.times { create(:user) }
      consultant = create(:user, email: 'filter.match@user.com')

      get :match,
          params: {
            job_id: job.id,
            filter: 'filter'
          }

      expect(response).to have_http_status(:ok)
      expect(data[0]['id']).to eq consultant.id
    end
  end

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

  describe 'post#award' do
    it 'should award a job to a user, and return awarded in the collaboration_state' do
      consultant = create(:user)

      post :award,
           params: {
             job_id: @job.id,
             id: consultant.id
           }

      expect(response).to have_http_status(:ok)
      expect(data['meta']['job']['collaboration_state']).to eq('awarded')
    end
  end

  describe 'post#reject' do
    it 'should remove a user from being a collaborator of invited or awarded' do
      consultant = create(:user)

      post :award,
           params: {
             job_id: @job.id,
             id: consultant.id
           }

      post :reject,
           params: {
             job_id: @job.id,
             id: consultant.id
           }

      expect(response).to have_http_status(:ok)
      expect(data['meta']).to eq({})
    end
  end

  describe 'get#collaborating' do
    it 'should without a filter, return max 5 jobs of "interested,invited,prospective,awarded,participant"' do
      6.times { create(:user) }
      6.times { create(:user).register_interest_in_jobs(@job) }
      6.times { @job.invite_users(create(:user)) }
      6.times do
        user = create(:user)
        @job.invite_users(user)
        user.register_interest_in_jobs(@job)
      end
      @job.award_to_user(create(:user))

      get :collaborating,
          params: {
            job_id: @job.id
          }

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq(16)

      states = data.map { |job| job['meta']['job']['collaboration_state'] }
      expect(states.count('interested')).to eq(5)
      expect(states.count('invited')).to eq(5)
      expect(states.count('prospective')).to eq(5)
      expect(states.count('awarded')).to eq(1)
      expect(states.count('participant')).to eq(0)
    end

    it 'should only return the filter requested when supplied' do
      6.times { create(:user) }
      6.times { @job.invite_users(create(:user)) }

      get :collaborating,
          params: {
            job_id: @job.id,
            state: :invited,
            limit: 3
          }

      expect(data.length).to eq(3)
      states = data.map { |job| job['meta']['job']['collaboration_state'] }
      expect(states.count('invited')).to eq(3)
    end
  end
end
