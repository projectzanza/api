require 'rails_helper'

RSpec.describe JobCreateService, type: :service do
  describe 'call' do
    before(:each) do
      allow_any_instance_of(JobCreateService).to receive(:create_chat_room).and_return(double(id: '123'))
    end

    it 'stores the chat room id of a job' do
      job_create_service = JobCreateService.new(create(:user), attributes_for(:job))
      expect(job_create_service.job.chat_room_id).to be_falsey
      job_create_service.call
      expect(job_create_service.job.chat_room_id).to be_truthy
    end

    it 'adds the job to the users job list' do
      user = create(:user)
      job_create_service = JobCreateService.new(user, attributes_for(:job))
      job_create_service.call
      expect(user.jobs.count).to eq 1
    end
  end
end
