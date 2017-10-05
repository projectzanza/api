# TODO: convert paperclip to background processing
# https://github.com/thoughtbot/paperclip/pull/2261
# it will mean the frontend polling for a new image too
# use a processing flag in the DB

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
