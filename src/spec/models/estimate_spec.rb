require 'rails_helper'

RSpec.describe Estimate, type: :model do
  before(:each) do
    @job = create(:job)
    @user = create(:user)
  end

  describe 'create' do
    it 'should assocaite multiple estimates to a job' do
      create(:estimate, job: @job, user: @user)
      create(:estimate, job: @job, user: @user)

      expect(@job.estimates.length).to eq 2
    end

    it 'should require a user and a job when being created' do
      expect { create(:estimate, job: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:estimate, user: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'update' do
    it 'should not allow user to update an accepted estimate' do
      estimate = create(:estimate)
      estimate.accept

      expect(estimate.update(total: 300)).to be_falsey
    end
  end

  describe 'accept' do
    it 'should allow only one estimate at a time to be accepted for a job' do
      est1 = create(:estimate, job: @job, user: @user)
      est2 = create(:estimate, job: @job, user: @user)

      expect(@job.estimates.length).to eq 2

      est1.accept
      expect(est1.reload.state).to eq 'accepted'
      expect(est2.reload.state).to eq 'rejected'

      est2.accept
      expect(est1.reload.state).to eq 'rejected'
      expect(est2.reload.state).to eq 'accepted'
    end

    it 'should allow one estimate per user to be accepted for a job' do
      @user2 = create(:user)

      est1 = create(:estimate, job: @job, user: @user)
      est2 = create(:estimate, job: @job, user: @user)
      est3 = create(:estimate, job: @job, user: @user2)

      est1.accept
      est2.accept
      est3.accept

      expect(est1.reload.state).to eq 'rejected'
      expect(est2.reload.state).to eq 'accepted'
      expect(est3.reload.state).to eq 'accepted'
    end
  end

  describe 'state machine' do
    before(:each) do
      @estimate = create(:estimate)
    end

    it 'should have a state of submitted when created' do
      expect(@estimate.state).to eq 'submitted'
    end

    it 'should allow transition from submitted to accepted' do
      @estimate.accept
      expect(@estimate.state).to eq 'accepted'
    end

    it 'should allow transition from rejected to accepted' do
      @estimate.reject
      @estimate.accept
      expect(@estimate.state).to eq 'accepted'
    end

    it 'should allow transition from submitted to rejected' do
      @estimate.reject
      expect(@estimate.state).to eq 'rejected'
    end

    it 'should allow transition from accepted to rejected' do
      @estimate.accept
      @estimate.reject!
      expect(@estimate.state).to eq 'rejected'
    end
  end
end
