class Account < ActiveRecord::Base
  belongs_to :user
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :delete_all
  has_many :articles, dependent: :delete_all

  validates :name, :birthday_on, :goal, :deadline_on, :payment_details, presence: true
  validates :budget, numericality: { other_than: 0 }

  before_update :set_changed
  after_save { create_default_product }

  def collected_percent
    return 0 if budget == 0
    ((collected / budget) * 100).round(2)
  end

  def age
    return if birthday_on.nil?
    now = Time.now.utc.to_date
    now.year - birthday_on.year - (birthday_on.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def title
    msg = self.name
    msg += ", #{self.age}" if self.birthday_on
    msg += ". #{self.goal}" unless self.goal.empty?
    msg
  end

private
  def set_changed
    return if (changed & %w(name birthday_on goal budget backers collected deadline_on
      payment_details overview avatar_url phone_number contact_person)).empty?
    self.was_changed = true
  end

  def create_default_product
    products.find_or_create_by!(
      title: 'Без винагороди',
      description: 'Зробити внесок без винагороди',
      visible: true,
      default: true,
      was_changed: false
    )
  end
end
