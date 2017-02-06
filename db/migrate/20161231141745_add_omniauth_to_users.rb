class AddOmniauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, default: ''
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :url, :string
    add_column :users, :avatar, :string
    add_column :users, :remote_avatar, :string
    add_column :users, :oauth_token, :string
    # add_column :users, :oauth_expires_at, :time
  end
end
