class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :account, index: true
      t.string :title, default: ''
      t.text :description, default: ''

      t.timestamps null: false
    end
  end
end
