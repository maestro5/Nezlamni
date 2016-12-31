class Order < ActiveRecord::Base
  belongs_to :product
  belongs_to :account

  before_save :delivery_recalculate!, if: :delivered_changed?

  def delivery!
    self.toggle!(:delivered)
  end

private

  def delivery_recalculate!
    if self.delivered?
      self.account.update_attributes(
        backers: self.account.backers + 1,
        collected: self.account.collected + self.contribution
        )
      self.product.update_attribute(:backers, (self.product.backers || 0) + 1)
    else
      self.account.update_attributes(
        backers: self.account.backers - 1,
        collected: self.account.collected - self.contribution
        )
      self.product.update_attribute(:backers, (self.product.backers || 1) - 1)
    end
  end # delivery_recalculate!
end # Order
