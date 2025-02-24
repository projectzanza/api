require 'rails_helper'

RSpec.describe Review, type: :model do
  before(:each) do
    @user = create(:user)
    @job = create(:job, user: @user)
    @consultant = create(:user)
  end

  describe 'create' do
    it 'should associate users, subjects and jobs to reviews' do
      review = Review.create(job: @job, user: @user, subject: @consultant, overall: 5)
      expect(review.user).to eq @user
      expect(review.subject).to eq @consultant
      expect(review.job).to eq @job

      expect(@consultant.reviews).to include(review)
      expect(@user.written_reviews).to include(review)
    end

    it 'should only a user create one review per job' do
      first_review = create(:review)
      expect { create(:review, user: first_review.user, job: first_review.job) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
