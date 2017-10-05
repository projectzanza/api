require 'rails_helper'

RSpec.describe GenerateUploadUrlService, type: :service do
  describe 'initialize' do
    it 'should raise an ArgumentError if the filename is nil' do
      expect { GenerateUploadUrlService.new }.to raise_error(ArgumentError)
    end

    it 'should raise an ArgumentError if the filename is not a valid format' do
      expect { GenerateUploadUrlService.new 'not_valid' }.to raise_error(ArgumentError)
    end
  end
end
