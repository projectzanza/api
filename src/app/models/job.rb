class Job < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  belongs_to :user
  has_many :messages

  validates :title, presence: true

  def as_json(options)
    super(options).merge(tag_list: tag_list)
  end
end
