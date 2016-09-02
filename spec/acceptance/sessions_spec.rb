require 'rails_helper'

feature 'Visitor items', %q{
  As a visitor
  I want to be able to visitor items
} do

  scenario 'when user login' do
    visit root_path
    
    expect(current_path).to eq root_path
    expect(page).not_to have_link 'Користувачі'
    expect(page).not_to have_link 'Моя сторінка'
    expect(page).to have_link 'Реєстрація'
    expect(page).to have_link 'Увійти'
  end
end # Visitor items

feature 'User login', %q{
  As a user
  I want to be able to login
} do

  let(:user) { create(:user) }
  
  scenario 'when user login' do
    sign_in user

    expect(current_path).to eq root_path
    expect(page).not_to have_link 'Користувачі'
    expect(page).to have_link 'Моя сторінка'
    expect(page).to have_link 'Замовлення'
    expect(page).to have_link 'Вийти'
  end
end # User login


feature 'Admin login', %q{
  As a admin
  I want to be able to login
} do

  let(:admin_user) { create(:user_admin) }

  scenario 'when admin login' do
    sign_in admin_user

    expect(current_path).to eq root_path
    expect(page).not_to have_link 'Моя сторінка'
    expect(page).to have_link 'Користувачі'
  end
end # Admin login
