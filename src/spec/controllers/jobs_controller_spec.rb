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

    it 'should return a job belonging to another user' do
      job = create(:job)

      get :show,
          params: { id: job.id }

      expect(data['id']).to eq job.id
    end
  end

  describe 'post#create' do
    before(:each) do
      allow_any_instance_of(JobCreateService).to receive(:create_chat_room).and_return(double(id: '123'))
    end

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
      expect(data['consultant_filter']['country']).to eq new_job_attr[:consultant_filter][:country].to_s
      expect(data['consultant_filter']['city']).to eq new_job_attr[:consultant_filter][:city].to_s
      expect(data['consultant_filter']['onsite']).to eq new_job_attr[:consultant_filter][:onsite]
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
      tag_list = %w[tag1 tag2]
      3.times { create(:job, tag_list: tag_list, user: @user) }

      login_user
      @user.update_attributes(tag_list: tag_list)

      get :match,
          params: { user_id: @user.id }

      expect(data.length).to eq 3
    end

    it 'should only return jobs where job creator has set allow_contact to true' do
      tag_list = %w[tag1 tag2]
      3.times { create(:job, tag_list: tag_list, user: @user) }
      2.times { create(:job, tag_list: tag_list, allow_contact: false, user: @user) }

      login_user
      @user.update_attributes(tag_list: tag_list)

      get :match,
          params: { user_id: @user.id }

      expect(data.length).to eq 3
    end

    it 'should not return jobs which the user is the creator of' do
      tag_list = %w[tag1 tag2]
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

  describe 'post#register_interest' do
    before(:each) do
      allow_any_instance_of(CollaboratorStateService).to receive(:invite_collaborator_to_chat).and_return(true)
    end

    it 'should register a user as interested in a job' do
      job = create(:job)

      post :register_interest,
           params: { id: job.id }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(job.id)
    end

    it 'should not allow the job owner to register an interest' do
      job = create(:job, user: @user)

      post :register_interest,
           params: { id: job.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#accept' do
    it 'should accept the job for the user then return all accepted jobs for that user' do
      job = create(:job, user: create(:user))
      create(:collaborator, user: @user, job: job).award

      post :accept,
           params: { id: job.id }

      expect(response).to have_http_status(:ok)
      expect(data.first['id']).to eq(job.id)
    end

    it 'should only allow acceptance of jobs the user has been awarded' do
      job = create(:job, user: create(:user))

      post :accept,
           params: { id: job.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'get#collaborating' do
    it 'without a filter, it should return max 5 jobs from each "interested,invited,prospective,awarded,accepted"' do
      6.times { create(:job) }
      6.times { create(:collaborator, user: @user, job: create(:job)).interested }
      6.times { create(:collaborator, user: @user, job: create(:job)).invite }
      6.times do
        job = create(:job)
        collab = create(:collaborator, user: @user, job: job)
        collab.invite
        collab.interested
      end
      6.times { create(:collaborator, job: create(:job), user: @user).award }
      6.times do
        job = create(:job)
        collab = create(:collaborator, user: @user, job: job)
        collab.award
        collab.accept
      end

      get :collaborating

      expect(response).to have_http_status(:ok)
      expect(data.length).to eq(25)

      states = data.map { |job| job['meta']['current_user']['collaboration_state'] }
      expect(states.count('interested')).to eq(5)
      expect(states.count('invited')).to eq(5)
      expect(states.count('prospective')).to eq(5)
      expect(states.count('awarded')).to eq(5)
      expect(states.count('accepted')).to eq(5)
    end

    it 'should return only the filter requested when supplied' do
      6.times { create(:job) }
      6.times { create(:collaborator, user: @user, job: create(:job)).interested }

      get :collaborating,
          params: {
            state: :interested,
            limit: 3
          }

      expect(data.length).to eq(3)
      states = data.map { |job| job['meta']['current_user']['collaboration_state'] }
      expect(states.count('interested')).to eq(3)
    end
  end

  describe 'post#complete' do
    it 'should set the job state as complete' do
      job = create(:job, user: create(:user))
      collab = create(:collaborator, user: @user, job: job)
      collab.award
      collab.accept

      post :complete,
           params: { id: job.id }

      expect(response).to have_http_status(200)
      expect(data['state']).to eq 'completed'
      expect(data['completed_at']).to be_truthy
    end

    it 'should not allow the owner to complete the job' do
      job = create(:job, user: @user)

      post :complete,
           params: { id: job.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'post#verify' do
    it 'should set the job state as verified' do
      job = create(:job, user: @user)
      consultant = create(:user)
      collab = create(:collaborator, user: consultant, job: job)
      collab.award
      collab.accept

      allow(Payment).to receive(:complete).and_return(true)
      post :verify,
           params: { id: job.id }

      expect(response).to have_http_status(200)
      expect(data['state']).to eq 'verified'
      expect(data['verified_at']).to be_truthy
    end

    it 'should only allow the client to verify the job' do
      job = create(:job, user: @user)
      consultant = create(:user)
      create(:collaborator, user: consultant, job: job).award

      login_user(consultant)

      allow(Payment).to receive(:complete).and_return(true)
      post :verify,
           params: { id: job.id }

      expect(response).to have_http_status(:not_found)
    end
  end
end
