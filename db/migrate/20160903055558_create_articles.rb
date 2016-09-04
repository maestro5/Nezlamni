class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.belongs_to :account, index: true
      t.string :title, default: ''
      t.text :description, default: ''
      t.string :link
      t.boolean :visible, default: true

      t.timestamps null: false
    end
  end
end
