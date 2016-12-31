class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :account, index: true
      t.string :title, default: ''
      t.text :description, default: ''

      t.boolean :visible, default: true
      t.boolean :was_changed, default: true
      
      t.timestamps null: false
    end
  end
end
