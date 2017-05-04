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
  end
end
