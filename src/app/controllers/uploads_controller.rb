class UploadsController < ApplicationController
  def create
    @upload_url_service = GenerateUploadUrlService.new(params[:filename])
    @upload_url_service.call
    render json: { data: @upload_url_service.signed_post }
  end
end
