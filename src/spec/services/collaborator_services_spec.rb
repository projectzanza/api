require 'rails_helper'

RSpec.describe Job, type: :service do
  describe 'initialize' do
    it 'will raise an error if job or user is nil' do
      expect{ CollaboratorService.new(create(:job), nil) }.to raise_error ArgumentError
      expect{ CollaboratorService.new(nil, create(:user)) }.to raise_error ArgumentError
    end

    it 'will create a new collaborator for every user/job combination' do
      job = create(:job)
      CollaboratorService.new(job, create(:user)).collaborator.save
      CollaboratorService.new(job, create(:user)).collaborator.save
      expect(Collaborator.where(job: job).count).to eq 2
    end

    it 'will not create two instances of the same collaboration' do
      job = create(:job)
      user = create(:user)
      CollaboratorService.new(job, user).collaborator.save
      CollaboratorService.new(job, user).collaborator.save
      expect(Collaborator.where(job: job, user: user).count).to eq 1
    end
  end

  describe 'event' do
    it 'will update the collaborator with the supplied event' do
      job = create(:job)
      user = create(:user)
      CollaboratorService.new(job, user).event = :interested
      expect(Collaborator.find_by(job: job, user: user).state).to eq 'interested'
    end

    it 'will update existing collaborators with the correct event' do
      job = create(:job)
      user = create(:user)
      CollaboratorService.new(job, user).event = :interested
      CollaboratorService.new(job, user).event = :award
      expect(Collaborator.find_by(job: job, user: user).state).to eq 'awarded'
    end
  end
end
