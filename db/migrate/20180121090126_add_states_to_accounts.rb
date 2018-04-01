class AddStatesToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :visible,     :boolean, default: false
    add_column :accounts, :locked,      :boolean, default: false
    add_column :accounts, :was_changed, :boolean, default: false
    add_column :accounts, :deleted,     :boolean, default: false
  end
end
