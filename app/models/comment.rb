class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  validates :body, presence: true

  def admin_or_owner?(current_user)
    return unless current_user
    current_user.admin? || account.user == current_user || user == current_user
  end

  def owner?(current_user)
    return unless current_user
    user == current_user
  end
end