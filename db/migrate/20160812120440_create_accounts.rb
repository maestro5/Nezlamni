class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.belongs_to :user, index: true

      t.string :name, default: ''
      t.date :birthday_on
      t.string :goal, default: ''
      t.decimal :budget, default: 0
      t.integer :backers, default: 0
      t.decimal :collected, default: 0
      t.date :deadline_on
      t.string :payment_details, default: ''
      t.text :overview, default: ''

      t.timestamps null: false
    end
  end
end
