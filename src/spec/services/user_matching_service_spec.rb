require 'rails_helper'

RSpec.describe UserMatchingService, type: :service do
  describe 'call' do
    it 'should save the consultant_filters for the request' do
      job = create(:job)

      ums = UserMatchingService.new(job, name: 'ted', save: true)
      ums.call

      expect(job.consultant_filter).to eq({ name: 'ted' }.stringify_keys)
    end

    it 'should not save the filters if the save flag is not set' do
      job = create(:job)
      original_filter = job.consultant_filter
      ums = UserMatchingService.new(job, { name: 'ted' }.stringify_keys)
      ums.call

      expect(job.consultant_filter).to eq(original_filter)
    end
  end
end
