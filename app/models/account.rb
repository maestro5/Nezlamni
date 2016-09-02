class Account < ActiveRecord::Base
  belongs_to :user
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :products, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  def collected_percent
    return 0 if budget == 0
    ((collected / budget) * 100).round(2)
  end

  def age
    return if birthday_on.nil?
    now = Time.now.utc.to_date
    now.year - birthday_on.year - (birthday_on.to_date.change(year: now.year) > now ? 1 : 0)
  end
end
