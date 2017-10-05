class GenerateUploadUrlService
  attr_reader :filename, :content_type, :signed_post

  SIGNED_POST_KEYS = %i[url fields].freeze

  def initialize(filename)
    @filename = filename
    raise ArgumentError, 'missing or invalid filename' unless @filename =~ /.+\..+/
    @content_type = MIME::Types.type_for(filename).first.content_type
    @signed_post = nil
  end

  def call
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['S3_BUCKET'])
    post = bucket.presigned_post(
      key: "uploads/#{SecureRandom.uuid}/#{filename}",
      success_action_status: '201',
      acl: 'public-read',
      content_type: 'image/png'
    )
    SIGNED_POST_KEYS.each { |key| @signed_post[key] = post.send(key) }
    true
  end
end
