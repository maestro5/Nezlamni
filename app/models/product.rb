class Product < ActiveRecord::Base
  belongs_to :account
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  validates :title, presence: true
end
