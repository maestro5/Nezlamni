class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.belongs_to :user, index: true

      t.string :name
      t.datetime :birthday
      t.string :goal
      t.decimal :budget, default: 0
      t.integer :backers, default: 0
      t.decimal :collected, default: 0
      t.datetime :deadline
      t.string :payment_details
      t.text :overview
      t.boolean :sended, default: false
      t.boolean :published, default: false
      t.boolean :visible, default: true
      t.boolean :locked, default: false

      t.timestamps null: false
    end
  end
end
