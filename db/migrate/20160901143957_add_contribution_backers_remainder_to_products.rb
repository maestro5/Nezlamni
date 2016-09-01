class AddContributionBackersRemainderToProducts < ActiveRecord::Migration
  def change
    add_column :products, :contribution, :integer, default: 0
    add_column :products, :backers, :integer, default: 0
    add_column :products, :remainder, :integer, default: 0
  end
end
