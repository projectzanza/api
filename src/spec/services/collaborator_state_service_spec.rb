require 'rails_helper'

RSpec.describe CollaboratorStateService, type: :service do
  describe 'initialize' do
    it 'will raise an error if job or user is nil' do
      expect { CollaboratorStateService.new(create(:job), nil) }.to raise_error ArgumentError
      expect { CollaboratorStateService.new(nil, create(:user)) }.to raise_error ArgumentError
    end

    it 'will create a new collaborator for every user/job combination' do
      job = create(:job)
      CollaboratorStateService.new(job, create(:user)).collaborator.save
      CollaboratorStateService.new(job, create(:user)).collaborator.save
      expect(Collaborator.where(job: job).count).to eq 2
    end

    it 'will not create two instances of the same collaboration' do
      job = create(:job)
      user = create(:user)
      CollaboratorStateService.new(job, user).collaborator.save
      CollaboratorStateService.new(job, user).collaborator.save
      expect(Collaborator.where(job: job, user: user).count).to eq 1
    end
  end

  describe 'event' do
    before(:each) do
      @job = create(:job)
      @user = create(:user)
    end

    it 'will update the collaborator with the supplied event' do
      CollaboratorStateService.new(@job, @user).call(:interested)
      expect(Collaborator.find_by(job: @job, user: @user).state).to eq 'interested'
    end

    it 'will update existing collaborators with the correct event' do
      CollaboratorStateService.new(@job, @user).call(:interested)
      CollaboratorStateService.new(@job, @user).call(:award)
      expect(Collaborator.find_by(job: @job, user: @user).state).to eq 'awarded'
    end

    it 'will send an email to the client when a consultant has marked themselves as interested' do
      CollaboratorStateService.new(@job, @user).call(:interested)
      expect(ActionMailer::Base.deliveries.last.to).to include @job.user.email
    end

    it 'will send an email to the client when a consultant has accepted a job' do
      CollaboratorStateService.new(@job, @user).call(:award)
      CollaboratorStateService.new(@job, @user).call(:accept)
      expect(ActionMailer::Base.deliveries.last.to).to include @job.user.email
    end

    it 'will send an email to the consultant when the client invites the consultant' do
      allow_any_instance_of(CollaboratorStateService).to receive(:invite_collaborator_to_chat).and_return(true)
      CollaboratorStateService.new(@job, @user).call(:invite)
      expect(ActionMailer::Base.deliveries.last.to).to include @user.email
    end

    it 'will send an email to the consultant when the client awards the consultant' do
      CollaboratorStateService.new(@job, @user).call(:award)
      expect(ActionMailer::Base.deliveries.last.to).to include @user.email
    end

    it 'will send an email to the consultant when the client rejects the consultant' do
      allow_any_instance_of(CollaboratorStateService).to receive(:kick_collaborator_from_chat).and_return(true)
      CollaboratorStateService.new(@job, @user).call(:reject)
      expect(ActionMailer::Base.deliveries.last.to).to include @user.email
    end
  end
end
