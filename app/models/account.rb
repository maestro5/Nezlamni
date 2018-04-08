class Account < ActiveRecord::Base
  belongs_to :user
  has_many :images, as: :imageable, dependent: :delete_all
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :delete_all
  has_many :articles, dependent: :delete_all
  has_many :comments, dependent: :delete_all

  # before_update :set_changed

  def authorized?(current_user)
    return true if current_user && current_user.admin?
    user.id == current_user.id
  end

  private
  # def set_changed
  #   return if (changed & %w(name birthday_on goal budget backers collected deadline_on
  #     payment_details overview avatar_url phone_number contact_person)).empty?
  #   self.was_changed = true
  # end
end
