require 'rails_helper'

RSpec.describe Estimate, type: :model do
  before(:each) do
    @job = create(:job)
    @user = create(:user)
  end

  describe 'create' do
    it 'should assocaite multiple estimates to a job' do
      Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))

      expect(@job.estimates.length).to eq 2
    end

    it 'should require a user and a job when being created' do
      est = Estimate.new(attributes_for(:estimate))
      expect(est.save).to be_falsey
    end
  end

  describe 'update' do
    it 'should not allow updating of an accepted estimate' do
      estimate = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      estimate.accept

      expect(estimate.update(total: 300)).to be_falsey
    end
  end

  describe 'accept' do
    it 'should set the state of the estimate to accepted' do
      estimate = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      expect(estimate.state).to eq 'submitted'

      estimate.accept
      expect(estimate.state).to eq 'accepted'
    end

    it 'should allow only one estimate at a time to be accepted for a job' do
      est1 = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      est2 = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))

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

      est1 = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      est2 = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user))
      est3 = Estimate.create(attributes_for(:estimate).merge(job: @job, user: @user2))

      est1.accept
      est2.accept
      est3.accept

      expect(est1.reload.state).to eq 'rejected'
      expect(est2.reload.state).to eq 'accepted'
      expect(est3.reload.state).to eq 'accepted'
    end
  end
end
