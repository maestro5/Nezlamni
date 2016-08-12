class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.belongs_to :user, index: true

      t.string :name, default: ''
      t.datetime :birthday
      t.string :goal, default: ''
      t.decimal :budget, default: 0
      t.integer :backers, default: 0
      t.decimal :collected, default: 0
      t.datetime :deadline
      t.string :payment_details, default: ''
      t.text :overview, default: ''
      t.boolean :sended, default: false
      t.boolean :published, default: false
      t.boolean :visible, default: true
      t.boolean :locked, default: false

      t.timestamps null: false
    end
  end
end
