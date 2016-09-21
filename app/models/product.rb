class Product < ActiveRecord::Base
  belongs_to :account
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  validates :title, presence: true

  before_create :set_timestamps

  def contributions_stat
    return if backers.nil? || backers == 0
    self.remainder ||= 0
    msg = self.remainder == 0 ? '' : ", залишилось #{self.remainder - self.backers} з #{self.remainder}"
    "#{self.backers} людей" + msg
  end

  private
    def set_timestamps
      self.created_at = Time.now
      self.updated_at = Time.now
    end
end
