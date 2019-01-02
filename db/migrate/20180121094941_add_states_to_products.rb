class AddStatesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :visible,     :boolean, default: true
    add_column :products, :was_changed, :boolean, default: true
    add_column :products, :default,     :boolean, default: false
  end
end
