require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'tag_list' do
    it 'should add tags on create' do
      job = create(:job, user: build(:user))
      expect(job.tag_list.length).to eq(3)
    end

    it 'should add tags on update' do
      job = create(:job, user: build(:user))
      job.update(tag_list: ['anotherTag'])
      expect(job.tag_list.length).to eq(1)
    end
  end
end
