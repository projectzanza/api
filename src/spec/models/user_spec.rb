require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'as_json' do
    before(:each) do
      @job = create(:job)
      @user = create(:user)
    end

    def collaboration_state_json
      JSON.parse(@user.to_json(job: @job))['meta']['job']['collaboration_state']
    end

    it 'returns collaboration state as "interested" when a user is invited to a project' do
      @user.register_interest_in_jobs(@job)
      expect(collaboration_state_json).to eq 'interested'
    end

    it 'returns collaboration state as "invited" when a user is invited to a project' do
      @job.invite_users(@user)
      expect(collaboration_state_json).to eq 'invited'
    end

    it 'returns collaboration state as "prospective" when a user is interested and invited to a project' do
      @user.register_interest_in_jobs(@job)
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

    it 'should show the estimate in the meta of the user' do
      estimate = Estimate.create(attributes_for(:estimate))
      @user.collaborators.create(job: @job, estimate: estimate, interested_at: Time.zone.now)

      expect(JSON.parse(@user.to_json(job: @job))['meta']['job']['estimate']).to be_truthy
    end
  end

  describe 'awarded_jobs' do
    it 'returns all jobs which are awarded but not accepted' do
      user = create(:user)
      consultant = create(:user)
      create(:job, user: user)

      j2 = create(:job, user: user)
      j2.award_to_user(consultant)

      j3 = create(:job, user: user)
      j3.award_to_user(consultant)
      consultant.accept_job(j3)

      jobs = consultant.awarded_jobs
      expect(jobs.count).to eq(1)
      expect(jobs.first.id).to eq(j2.id)
    end
  end

  describe 'before_validation_on_create' do
    it 'should set name, nickname and rc_password' do
      user = User.create(email: 'abc@abc.com')

      expect(user.name).to eq('abc')
      expect(user.nickname).to match(/abc\d{3}/)
      expect(user.rc_password).to be_truthy
    end

    it 'should not override name,nickname or rc_password' do
      user = User.create(
        email: 'abc@abc.com',
        name: 'name',
        nickname: 'nickname',
        rc_password: '12345'
      )

      expect(user.name).to eq('name')
      expect(user.nickname).to eq('nickname')
      expect(user.rc_password).to eq('12345')
    end

    it 'validated that name,nickname,email is present' do
      user = User.create

      expect(user.errors[:email]).to be_truthy
      expect(user.errors[:name]).to be_truthy
      expect(user.errors[:nickname]).to be_truthy
    end
  end

  describe 'filter' do
    before(:each) do
      2.times { create(:user) }
    end

    it 'should search for a user by email address' do
      user = create(:user, email: 'filter.match@user.com')
      expect(User.filter('filter').first.id).to eq user.id
    end

    it 'should search for a user by nickname' do
      user = create(:user, nickname: 'filter.match897')
      expect(User.filter('filter').first.id).to eq user.id
    end

    it 'should search for a user by name' do
      user = create(:user, name: 'filter match')
      expect(User.filter('filter').first.id).to eq user.id
    end

    it 'should search for a user disregarding case' do
      user = create(:user, name: 'Filter Match')
      expect(User.filter('filter').first.id).to eq user.id
    end
  end
end
