class Product < ActiveRecord::Base
  belongs_to :account
  has_many :orders, dependent: :destroy

  validates :title, presence: true
end
