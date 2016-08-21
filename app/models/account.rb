class Account < ActiveRecord::Base
  belongs_to :user
  has_many :products, dependent: :destroy

  def collected_percent
    ((collected / budget) * 100).round(2)
  end
end
