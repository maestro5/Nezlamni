class Article < ActiveRecord::Base
  belongs_to :account

  def check_link!
    prefix = 'http://'
    return if self.link.nil? || self.link.empty? || self.link.include?(prefix)
    self.update_attribute(:link, prefix + self.link)
  end

  def admin_owner_unlocked?(current_user)
    return false if current_user.nil?
    current_user.admin? ||
    (current_user.accounts.include?(self.account) && !self.account.locked?)
  end
end
