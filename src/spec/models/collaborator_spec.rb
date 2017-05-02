require 'rails_helper'

RSpec.describe Collaborator, type: :model do
  describe 'collaborator_state_present' do
    it 'should specify a state when creating a collaborator' do
      expect { Collaborator.create!(job: create(:job), user: create(:user)) }
        .to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe 'one_awarded_user_per_job' do
    it 'should only award a job to one user' do
      job = create(:job)

      Collaborator.create(job: job, user: create(:user), awarded_at: Time.zone.now)
      expect { Collaborator.create!(job: job, user: create(:user), awarded_at: Time.zone.now) }
        .to raise_error ActiveRecord::RecordInvalid
    end
  end
end
