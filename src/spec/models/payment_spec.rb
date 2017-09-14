require 'rails_helper'
require_relative '../../app/exceptions/zanza/payment_exception'

RSpec.describe Payment, type: :model do
  describe 'save_payment' do
    before { StripeMock.start }
    after { StripeMock.stop }
    before(:each) do
      @job = create(:job)
      @estimate = create(:estimate, job: @job, user: create(:user))
      @charge = Stripe::Charge.create(
        source: StripeMock.generate_card_token,
        amount: 100,
        currency: 'usd'
      )
    end

    it 'should successfully save if status is succeeded' do
      expect(Payment.save_payment_response(@charge, @job, @estimate)).to be_truthy
    end
  end

  describe 'complete' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before(:each) do
      @job = create(:job)
      @user = create(:user)
    end

    it 'should raise an error if there is no recipient' do
      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should raise an error if there is no estimate' do
      create(:collaborator, job: @job, user: @user).award
      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should raise an error if the payment token is not available' do
      create(:collaborator, job: @job, user: @user).award
      @estimate = create(:estimate, user: @user, job: @job)
      @estimate.accept

      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentPreConditionsNotMet)
    end

    it 'should save the charge response, when all valid conditions are met' do
      @estimate = create(:estimate, user: @user, job: @job)
      create(:collaborator, job: @job, user: @user).award
      @estimate.accept
      card_token = StripeMock.generate_card_token
      card = @job.user.add_card(card_token)
      @job.update!(payment_card_id: card['id'])

      expect(Payment.complete(@job)).to be_truthy
    end

    it 'should raise a payment exception if the charge is not successful' do
      card_token = StripeMock.generate_card_token
      create(:collaborator, job: @job, user: @user).award
      create(:estimate, user: @user, job: @job).accept
      card = @job.user.add_card(card_token)
      @job.update!(payment_card_id: card['id'])

      StripeMock.prepare_card_error(:card_declined)
      expect { Payment.complete(@job) }.to raise_error(Zanza::PaymentException)
    end
  end
end
