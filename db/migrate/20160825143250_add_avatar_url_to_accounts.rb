class AddAvatarUrlToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :avatar_url, :string
  end
end
