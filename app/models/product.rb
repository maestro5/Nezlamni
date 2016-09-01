class Product < ActiveRecord::Base
  belongs_to :account
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  validates :title, presence: true

  def contributions_stat
    return if backers == 0
    msg = remainder == 0 ? '' : ", залишилось #{remainder - backers} з #{remainder}"
    "#{backers} людей" + msg
  end
end
