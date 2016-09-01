class AddAvatarUrlToProducts < ActiveRecord::Migration
  def change
    add_column :products, :avatar_url, :string
  end
end
