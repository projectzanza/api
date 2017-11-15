require 'rails_helper'

RSpec.describe Job, type: :service do
  describe 'event=(new_state)' do
    before(:each) do
      @job = create(:job)
      @consultant = create(:user)
      collab = create(:collaborator, job: @job, user: @consultant)
      collab.award
      collab.accept
    end

    it 'updates the state of the job' do
      JobService.new(@job).complete
      expect(@job.state).to eq 'completed'
    end

    it 'sends an email to the client when the job is completed' do
      JobService.new(@job).complete
      expect(ActionMailer::Base.deliveries.last.to).to include @job.user.email
    end

    it 'sends an email to the consultant when the job is verified' do
      JobService.new(@job).verify
      expect(ActionMailer::Base.deliveries.last.to).to include @consultant.email
    end
  end
end
