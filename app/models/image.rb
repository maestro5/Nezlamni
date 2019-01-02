class Image < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :imageable, polymorphic: true

  validates :image, presence: true
  validate :image_size_validation
  validates_integrity_of :image

private
  def image_size_validation
    errors[:image] << "should be less than 5MB" if image.size > 5.megabytes
  end
end
