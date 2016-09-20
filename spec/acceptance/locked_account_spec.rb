require_relative '../acceptance_helper'

feature 'Admin lock an account', %q{
  As a admin
  I want to be able to lock an account
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }

  scenario 'when admin lock user account' do
    # user edits account, adds and edits a product
    sign_in user
    click_on 'Моя сторінка'
    click_on 'Редагувати'
    fill_in 'account[name]', with: user.email
    click_on 'Зберегти'

    click_on 'Додати товар'
    fill_in 'product[title]', with: 'title'
    click_on 'Зберегти'

    within('.product') do
      click_on 'Редагувати'
    end

    fill_in 'product[title]', with: 'edited product'
    click_on 'Зберегти'

    expect(page).to have_content 'edited product'

    click_on 'Вийти'

    # admin lock user account
    sign_in admin_user
    click_on 'Користувачі'
    click_on 'Заблокувати'
    
    expect(page).to have_link 'Розблокувати'
    expect(page).not_to have_link 'Заблокувати'

    # admin can edit locked user account
    click_on user.email
    
    find('#edit_account').click
    fill_in 'account[name]', with: 'Bob'
    click_on 'Зберегти'

    expect(page).to have_content 'Bob'

    # admin can edit locked user products
    within('.product') do
      click_on 'Редагувати'
    end
    fill_in 'product[title]', with: 'admin edited product'
    click_on 'Зберегти'

    expect(page).to have_content 'admin edited product'

    click_on 'Вийти'

    # user can't edit locked account and can't add, edit, delete a product
    sign_in user
    click_on 'Моя сторінка'

    expect(page).not_to have_link 'Редагувати'
    expect(page).not_to have_link 'Додати товар'
    
    within('.product') do
      expect(page).not_to have_link 'Редагувати'
      expect(page).not_to have_link 'Видалити'
    end

    visit edit_account_path(user.account)
    expect(current_path).to eq root_path

    visit edit_product_path(user.account.products.first)
    expect(current_path).to eq root_path

    visit new_account_product_path(user.account)
    expect(current_path).to eq root_path
  end # when admin lock user account
end # Admin lock an account
