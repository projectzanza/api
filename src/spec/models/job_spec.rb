require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'tag_list' do
    it 'should add tags on create' do
      job = create(:job)
      expect(job.tag_list.length).to eq(3)
    end

    it 'should add tags on update' do
      job = create(:job)
      job.update(tag_list: ['anotherTag'])
      expect(job.tag_list.length).to eq(1)
    end
  end

  describe 'proposed_start_end_dates' do
    it 'should not allow end date to be before start date' do
      job_attrs = attributes_for(:job)
      job_attrs['proposed_start_at'] = Time.zone.now + 1.hour
      job_attrs['proposed_end_at'] = Time.zone.now - 1.day

      job = Job.new(job_attrs)
      expect(job.valid?).to eq(false)
    end

    it 'should allow valid end dates if start date is nil' do
      job_attrs = attributes_for(:job)
      job_attrs['proposed_start_at'] = nil
      job_attrs['proposed_end_at'] = Time.zone.now + 1.day

      job = Job.new(job_attrs)
      expect(job.valid?).to eq(true)
    end
  end

  describe 'allow_contact' do
    it 'defaults to true' do
      job = Job.create(title: 'title', user: build(:user))
      expect(job.allow_contact).to eq(true)
    end
  end

  describe 'awarded_user' do
    it 'should return the user that has been awarded the job' do
      job = create(:job)
      user = create(:user)
      create(:collaborator, job: job, user: user).award
      expect(job.awarded_user).to eq user
    end
  end

  describe 'awarded_estimate' do
    it 'should return the awarded estimate of the awarded user' do
      job = create(:job)
      consultant = create(:user)
      collab = create(:collaborator, job: job, user: consultant)
      collab.award
      collab.accept

      estimate = create(:estimate, user: consultant, job: job)
      estimate.accept

      expect(job.reload.awarded_estimate).to eq estimate
    end
  end

  describe 'verify' do
    before(:each) do
      @user = create(:user)
      @job = create(:job, user: @user, scope_count: 3)
    end

    it 'should allow the job owner to verify the job' do
      @job.verify(user: @user)
      expect(@job.verified_at).to be_truthy
    end
  end

  describe 'state' do
    it 'should return open state if the job is new' do
      expect(create(:job).state).to eq('open')
    end

    it 'should return completed state if the job has been completed' do
      job = create(:job)
      job.complete
      expect(job.state).to eq('completed')
    end

    it 'should return verified state if the job has been verified' do
      job = create(:job)
      job.verify
      expect(job.state).to eq('verified')
    end
  end

  describe 'as_json' do
    before(:each) do
      @job = create(:job)
      @user = create(:user)
    end

    def collaboration_state_json
      JSON.parse(@job.reload.to_json(user: @user))['meta']['current_user']['collaboration_state']
    end

    it 'returns collaboration state of the user to the job' do
      create(:collaborator, user: @user, job: @job).interested
      expect(collaboration_state_json).to eq 'interested'
    end

    it 'does not return collaboration_state if the user is not a collaborator' do
      expect(JSON.parse(@job.to_json(user: @user))['meta']).to eq({})
    end

    it 'should show the estimate in the meta of the job' do
      create(:collaborator, user: @user, job: @job).interested
      create(:estimate, job: @job, user: @user)
      expect(JSON.parse(@job.reload.to_json(user: @user))['meta']['current_user']['estimates'].length).to eq 1
    end
  end
end
