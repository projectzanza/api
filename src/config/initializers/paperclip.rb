Paperclip::Attachment.default_options.merge!(
  url:                  ':s3_domain_url',
  path:                 ':class/:attachment/:id/:style/:filename',
  storage:              :s3,
  s3_permissions:       'public-read',
  s3_protocol:          'http',
  s3_region:            ENV['AWS_REGION'],
  bucket:               ENV['S3_BUCKET'],
  default_url:          '/assets/images/defaults/:style/missing.png'
)
