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

  describe 'invited_users' do
    it 'does not error on duplicate invited users' do
      job = create(:job)

      job.invite_user(create(:user))
      expect(job.invite_user(create(:user))).to be_truthy
    end

    it 'is not able to invite the same user twice' do
      job = create(:job)
      user = create(:user)
      job.invite_user(user)
      expect { job.invite_user(user) }.to raise_error ActiveRecord::RecordNotSaved
    end
  end

  describe 'interested_users' do
    it 'does not error on duplicate interested_users' do
      job = create(:job)
      job.register_interested_user(create(:user))
      expect(job.register_interested_user(create(:user))).to be_truthy
    end

    it 'does not record the second instance of duplicate interested users' do
      job = create(:job)
      user = create(:user)
      job.register_interested_user(user)
      expect { job.register_interested_user(user) }.to raise_error ActiveRecord::RecordNotSaved
    end
  end

  describe 'collaborators' do
    it 'can make a user as interested, then update them to be also invited' do
      job = create(:job)
      consultant = create(:user)

      job.register_interested_user(consultant)
      job.invite_user(consultant)

      expect(job.collaborating_users.count).to eq(1)
      expect(job.collaborators.where(state: :prospective).count).to eq(1)
    end
  end

  describe 'award_to_user' do
    it 'should award a job to a user' do
      job = create(:job)
      consultant = create(:user)

      job.award_to_user(consultant)

      expect(job.awarded_user).to eq(consultant)
    end

    it 'should only allow awarding of the job to one user at a time' do
      job = create(:job)
      consultant = create(:user)
      consultant2 = create(:user)

      job.award_to_user(consultant)
      expect { job.award_to_user(consultant2) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should allow collaborator actions with other users after awarding a job to a user' do
      job = create(:job)
      consultant1 = create(:user)
      consultant2 = create(:user)

      job.award_to_user(consultant1)
      job.invite_user(consultant2)
      expect(job.invited_users).to include(consultant2)
      expect(job.invited_users.count).to eq 1
    end
  end

  describe 'awarded_user' do
    it 'should return the user that has been awarded the job' do
      job = create(:job)
      user = create(:user)
      job.award_to_user(user)

      expect(job.awarded_user).to eq user
    end
  end

  describe 'awarded_estimate' do
    it 'should return the awarded estimate of the awarded user' do
      job = create(:job)
      user = create(:user)
      job.award_to_user(user)
      estimate = create(:estimate, user: user, job: job)
      estimate.accept

      expect(job.awarded_estimate).to eq estimate
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

    it 'should return complete state if the job has been verified' do
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
      JSON.parse(@job.to_json(user: @user))['meta']['current_user']['collaboration_state']
    end

    it 'returns collaboration state as "interested" when a user is invited to a project' do
      @job.register_interested_user(@user)
      expect(collaboration_state_json).to eq 'interested'
    end

    it 'returns collaboration state as "invited" when a user is invited to a project' do
      @job.invite_user(@user)
      expect(collaboration_state_json).to eq 'invited'
    end

    it 'returns collaboration state as "prospective" when a user is interested and invited to a project' do
      @job.register_interested_user(@user)
      @job.invite_user(@user)
      expect(collaboration_state_json).to eq 'prospective'
    end

    it 'returns collaboration state as "awarded" when a user is awarded a project' do
      @job.award_to_user(@user)
      expect(collaboration_state_json).to eq 'awarded'
    end

    it 'returns collaboration state as "participant" when a user is awarded and accepts the project' do
      @job.award_to_user(@user)
      @job.accepted_by(@user)
      expect(collaboration_state_json).to eq 'participant'
    end

    it 'does not return collaboration_state if the user is not a collaborator' do
      expect(JSON.parse(@job.to_json(user: @user))['meta']).to eq({})
    end

    it 'should show the estimate in the meta of the job' do
      @job.collaborators.create(user: @user, interested_at: Time.zone.now)
      create(:estimate, job: @job, user: @user)

      expect(JSON.parse(@job.to_json(user: @user))['meta']['current_user']['estimates'].length).to eq 1
    end
  end
end
