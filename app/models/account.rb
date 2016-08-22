class Account < ActiveRecord::Base
  belongs_to :user
  has_many :products, dependent: :destroy

  def collected_percent
    return 0 if budget == 0
    ((collected / budget) * 100).round(2)
  end
end
