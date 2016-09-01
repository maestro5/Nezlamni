class AddPhoneNumberAndContactPersonToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :phone_number, :string
    add_column :accounts, :contact_person, :string
  end
end
