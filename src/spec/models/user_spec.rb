require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'as_json' do
    it 'returns meta data for the job supplied in the options' do
      job = create(:job)
      user = create(:user)

      user.invite_to_jobs(job)
      expect(JSON.parse(user.to_json(job: job))['meta']['job']['collaboration_state']).to eq('invited')

      job2 = create(:job)
      user.register_interest_in_jobs([job, job2])
      expect(JSON.parse(user.to_json(job: job))['meta']['job']['collaboration_state']).to eq('collaborator')
      expect(JSON.parse(user.to_json(job: job2))['meta']['job']['collaboration_state']).to eq('interested')
    end

    it 'does not return collaboration_state if the user is not a collaborator' do
      job = create(:job)
      user = create(:user)
      expect(JSON.parse(user.to_json(job: job))['meta']).to eq({})
    end
  end
end
