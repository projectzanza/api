require 'rails_helper'
require_relative '../../app/exceptions/zanza/payment_exception'

RSpec.describe Payment, type: :model do
  describe 'save_payment' do
    before(:each) do
      @job = create(:job)
      @estimate = create(:estimate)
    end

    it 'should successfully save if status is succeeded' do
      charge = attributes_for(:payment_provider_charge_response).stringify_keys
      expect(Payment.save_payment_response(charge, @job, @estimate)).to be_truthy
    end

    it 'should raise an error if payment is not successful' do
      charge = attributes_for(:payment_provider_charge_response, success: false).stringify_keys
      expect { Payment.save_payment_response(charge, @job, @estimate) }.to raise_error(Zanza::PaymentException)
    end
  end

  describe 'complete' do
    before(:each) do
      @job = create(:job)
      @user = create(:user)
    end

    it 'should raise an error if there is no recipient' do
      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should raise an error if there is no estimate' do
      @job.award_to_user(@user)
      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should raise an error if the payment token is not available' do
      @job.award_to_user(@user)
      @estimate = create(:estimate, user: @user)
      collaborator = @job.reload.collaborators.find_by(user: @user)
      collaborator.update_attributes!(estimate: @estimate)

      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should save the charge response, when all valid conditions are met' do
      @job.award_to_user(@user)
      @estimate = create(:estimate, user: @user)
      collaborator = @job.reload.collaborators.find_by(user: @user)
      collaborator.update_attributes!(estimate: @estimate)

      payment_token = attributes_for(:payment_token)
      @job.create_payment_token(payment_token)

      allow(Stripe::Charge)
        .to receive(:create)
        .and_return(attributes_for(:payment_provider_charge_response).stringify_keys)
      expect(Payment.complete(@job)).to be_truthy
    end
  end
end
