class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :account, index: true
      t.string :title, default: ''
      t.text :description, default: ''

      t.datetime :prev_updated_at, default: '0001-01-01'
      t.boolean :visible, default: false
      t.datetime :created_at, default: Time.now
      t.datetime :updated_at, default: Time.now
    end
  end
end
