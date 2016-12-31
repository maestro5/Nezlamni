class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :product, index: true
      
      t.string :address, default: ''
      t.string :recipient, default: ''
      t.string :phone, default: ''
      t.boolean :delivered, default: false

      t.timestamps null: false
    end
  end
end
