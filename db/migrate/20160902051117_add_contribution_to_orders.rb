class AddContributionToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contribution, :decimal, default: 0
  end
end
