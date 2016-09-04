class Article < ActiveRecord::Base
  belongs_to :account

  def check_link!
    prefix = 'http://'
    return if self.link.empty?
    return if self.link.include? prefix
    self.link = prefix + self.link
    self.save
  end
end
