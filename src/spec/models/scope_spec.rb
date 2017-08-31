require 'rails_helper'

RSpec.describe Scope, type: :model do
  describe 'states' do
    before(:each) do
      @scope = create(:scope)
    end

    it 'should have state of "open" when created' do
      scope = create(:scope)
      expect(scope.state).to eq 'open'
    end

    it 'should allow transition from open to completed' do
      @scope.complete
      expect(@scope.state).to eq 'completed'
    end

    it 'should allow transition from rejected to completed' do
      @scope.reject
      @scope.complete
      expect(@scope.state).to eq 'completed'
    end

    it 'should allow transition from open to verified' do
      @scope.verify
      expect(@scope.state).to eq 'verified'
    end

    it 'should allow transition from completed to verified' do
      @scope.complete
      @scope.verify
      expect(@scope.state).to eq 'verified'
    end

    it 'should allow transition from rejected to verified' do
      @scope.reject
      @scope.verify
      expect(@scope.state).to eq 'verified'
    end

    it 'should allow transition from open to rejected' do
      @scope.reject
      expect(@scope.state).to eq 'rejected'
    end

    it 'should allow transition from completed to rejected' do
      @scope.complete
      @scope.reject
      expect(@scope.state).to eq 'rejected'
    end

    it 'should allow transition from verified to rejected' do
      @scope.verify
      @scope.reject
      expect(@scope.state).to eq 'rejected'
    end
  end
end
