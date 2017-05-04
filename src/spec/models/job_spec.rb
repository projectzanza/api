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

      job.invite_users(create(:user))
      expect(job.invite_users(create(:user))).to be_truthy
    end

    it 'does not record the second instance of duplicate invited users' do
      job = create(:job)
      user = create(:user)
      2.times { job.invite_users(user) }
      expect(job.invited_users.count).to eq(1)
    end
  end

  describe 'interested_users' do
    it 'does not error on duplicate interested_users' do
      job = create(:job)
      job.register_interested_users(create(:user))
      expect(job.register_interested_users(create(:user))).to be_truthy
    end

    it 'does not record the second instance of duplicate interested users' do
      job = create(:job)
      user = create(:user)
      2.times { job.register_interested_users(user) }
      expect(job.interested_users.count).to eq(1)
    end
  end

  describe 'collaborators' do
    it 'can make a user as interested, then update them to be also invited' do
      job = create(:job)
      consultant = create(:user)

      job.register_interested_users(consultant)
      job.invite_users(consultant)

      expect(job.collaborating_users.count).to eq(1)
      expect(job.prospective_users.count).to eq(1)
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
      @job.register_interested_users(@user)
      expect(collaboration_state_json).to eq 'interested'
    end

    it 'returns collaboration state as "invited" when a user is invited to a project' do
      @job.invite_users(@user)
      expect(collaboration_state_json).to eq 'invited'
    end

    it 'returns collaboration state as "prospective" when a user is interested and invited to a project' do
      @job.register_interested_users(@user)
      @job.invite_users(@user)
      expect(collaboration_state_json).to eq 'prospective'
    end

    it 'returns collaboration state as "awarded" when a user is awarded a project' do
      @job.award_to_user(@user)
      expect(collaboration_state_json).to eq 'awarded'
    end

    it 'returns collaboration state as "participant" when a user is awarded and accepts the project' do
      @job.award_to_user(@user)
      @user.accept_job(@job)
      expect(collaboration_state_json).to eq 'participant'
    end

    it 'does not return collaboration_state if the user is not a collaborator' do
      expect(JSON.parse(@job.to_json(user: @user))['meta']).to eq({})
    end
  end
end
