class Product < ActiveRecord::Base
  belongs_to :account
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  validates :title, presence: true

  before_update :set_changed

  DEFAULT_ATTRIBUTES = {
    title: 'Без винагороди',
    description: 'Зробити внесок без винагороди',
    visible: true,
    default: true,
    was_changed: false
  }

  def contributions_stat
    return if backers.nil? || backers == 0
    self.remainder ||= 0
    msg = self.remainder == 0 ? '' : ", залишилось #{self.remainder - self.backers} з #{self.remainder}"
    "#{self.backers} людей" + msg
  end

private
  def set_changed
    return if (changed & %w(title description avatar_url contribution backers remainder)).empty?
    self.was_changed = true
  end
end
