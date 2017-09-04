require 'rails_helper'

RSpec.describe Collaborator, type: :model do
  describe 'one_awarded_user_per_job' do
    it 'should only award a job to one user' do
      job = create(:job)

      Collaborator.create(job: job, user: create(:user)).award

      expect do
        c = Collaborator.create(job: job, user: create(:user))
        c.award
        c.save!
      end.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe 'state machine' do
    before(:each) do
      @collaborator = create(:collaborator)
    end

    it 'should allow transition from init to invited' do
      @collaborator.invite
      expect(@collaborator.state).to eq('invited')
      expect(@collaborator.invited_at).to be_truthy
    end

    it 'should allow transition from init to interested' do
      @collaborator.interested
      expect(@collaborator.state).to eq('interested')
      expect(@collaborator.interested_at).to be_truthy
    end

    it 'should allow transition from invited to prospective when contractor is interested' do
      @collaborator.invite
      @collaborator.interested
      expect(@collaborator.state).to eq('prospective')
      expect(@collaborator.invited_at).to be_truthy
      expect(@collaborator.interested_at).to be_truthy
    end

    it 'should allow transition from interested to prospective when contractor is invited' do
      @collaborator.interested
      @collaborator.invite
      expect(@collaborator.state).to eq('prospective')
      expect(@collaborator.invited_at).to be_truthy
      expect(@collaborator.interested_at).to be_truthy
    end

    it 'should allow transition from init to awarded when contractor is awarded' do
      @collaborator.award
      expect(@collaborator.state).to eq('awarded')
      expect(@collaborator.awarded_at).to be_truthy
    end

    it 'should allow transition from invited to awarded when contractor is awarded' do
      @collaborator.invite
      @collaborator.award
      expect(@collaborator.state).to eq('awarded')
    end

    it 'should allow transition from interested to awarded when contractor is awarded' do
      @collaborator.interested
      @collaborator.award
      expect(@collaborator.state).to eq('awarded')
    end

    it 'should allow transition from prospective to awarded when contractor is awarded' do
      @collaborator.invite
      @collaborator.award
      expect(@collaborator.state).to eq('awarded')
    end

    it 'should allow transition from rejected to awarded when contractor is awarded' do
      @collaborator.reject
      @collaborator.award
      expect(@collaborator.state).to eq('awarded')
    end

    it 'should allow transition from awarded to accepted when contractor accepts the awarded job' do
      @collaborator.award
      @collaborator.accept
      expect(@collaborator.state).to eq('accepted')
      expect(@collaborator.accepted_at).to be_truthy
    end

    it 'should not allow transition from invited to accepted' do
      @collaborator.invite
      expect(@collaborator.can_accept?).to be_falsey
      expect(@collaborator.accept).to be_falsey
      expect(@collaborator.accepted_at).to be_falsey
    end

    it 'should allow transition from awarded to rejected when the contractor is rejected' do
      @collaborator.award
      @collaborator.reject
      expect(@collaborator.state).to eq('rejected')
      expect(@collaborator.rejected_at).to be_truthy
    end
  end
end
