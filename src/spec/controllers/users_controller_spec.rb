require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    login_user
    @job = create(:job, user: @user)
  end

  describe 'get#index' do
    it 'should return all users in the system' do
      3.times { create(:user) }

      get :index

      expect(response).to have_http_status(:ok)
      # include the logged in user in the count
      expect(data.length).to eq 4
    end
  end

  describe 'get#show' do
    it 'should return a user' do
      user = create(:user)

      get :show,
          params: {
            id: user.id
          }

      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq user.id
    end
  end

  describe 'put#update' do
    it 'should return updated user information is successful' do
      user = attributes_for(:user)
      expect(user['email']).not_to eq(@user.name)

      put :update,
          params: user.merge(id: @user.id)

      expect(response).to have_http_status(:ok)
      expect(data['email']).to eq user[:email]
      expect(data['headline']).to eq user[:headline]
      expect(data['summary']).to eq user[:summary]
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
    before(:each) do
      allow_any_instance_of(CollaboratorStateService).to receive(:invite_collaborator_to_chat).and_return(true)
    end

    it 'should mark the user as invited to a job' do
      consultant = create(:user)

      post :invite,
           params: {
             id: consultant.id,
             job_id: @job.id
           }

      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq(consultant.id)
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
    before(:each) do
      allow_any_instance_of(CollaboratorStateService).to receive(:kick_collaborator_from_chat).and_return(true)
    end

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
      expect(data['meta']['job']['collaboration_state']).to eq('rejected')
    end
  end

  describe 'get#collaborating' do
    it 'should without a filter, return max 5 jobs of "interested,invited,prospective,awarded,accepted"' do
      6.times { create(:user) }
      6.times { create(:collaborator, job: @job, user: create(:user)).interested }
      6.times { create(:collaborator, job: @job, user: create(:user)).invite }
      6.times do
        collab = create(:collaborator, job: @job, user: create(:user))
        collab.invite
        collab.interested
      end
      create(:collaborator, job: @job, user: create(:user)).invite
      create(:collaborator, job: @job, user: create(:user)).award

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
      expect(states.count('accepted')).to eq(0)
    end

    it 'should only return the filter requested when supplied' do
      6.times { create(:user) }
      6.times { create(:collaborator, job: @job, user: create(:user)).invite }

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

  describe 'post#certify' do
    before(:each) do
      @admin = create(:user, admin: true)
      @user = create(:user)
    end

    it 'should set the certified flag to true' do
      login_user(@admin)

      post :certify,
           params: { id: @user.id }

      expect(response).to have_http_status(:ok)
      expect(data['certified']).to eq true
    end

    it 'should block non admin users from certifying a user' do
      post :certify,
           params: { id: @user.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#decertify' do
    before(:each) do
      @admin = create(:user, admin: true)
      @user = create(:user, certified: true)
    end

    it 'should set the certified flag to false' do
      login_user(@admin)

      post :decertify,
           params: { id: @user.id }

      expect(response).to have_http_status(:ok)
      expect(data['certified']).to eq false
    end

    it 'should block non admin users from certifying a user' do
      post :decertify,
           params: { id: @user.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
