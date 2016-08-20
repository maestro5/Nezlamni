require 'rails_helper'

feature 'Admin checks a product', %q{
  As a admin
  I want to be able to check a product
} do

  let(:user) { create(:user) }
  let(:admin_user) { create(:user_admin) }
  let(:title) { 'product title' }
  let(:description) { 'product description' }
  let(:new_description) { 'new product description' }

  before { user.account.update_attribute(:name, 'user') }
  
  scenario 'when user creates/updates and admin checks a product' do
    # user creates a product from account
    sign_in user

    click_on 'Моя сторінка'

    click_on 'Додати товар'
    fill_in 'product[title]', with: title
    fill_in 'product[description]', with: description
    
    expect { click_on 'Зберегти' }.to change(user.account.products, :count).by(1)
    expect(current_path).to eq account_path user.account
    expect(page).to have_content title
    expect(page).to have_content description
    expect(page).to have_link 'Додати товар'

    within('#product_0') do
      expect(page).to have_link 'Редагувати'
      expect(page).to have_link 'Видалити'
      expect(page).not_to have_link 'Перевірено'
    end

    click_on 'Вийти'

    # admin checks a new product from product page
    sign_in admin_user

    click_on 'Товари'
    expect(page).to have_selector 'tr.warning'

    click_on title
    click_on 'Перевірено'

    click_on 'Товари'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.warning'

    click_on 'Вийти'

    # user updates a product from account
    sign_in user

    click_on 'Моя сторінка'

    within('#product_0') do
      click_on 'Редагувати'
    end
    fill_in 'product[description]', with: new_description
    click_on 'Зберегти'

    expect(page).to have_content new_description

    click_on 'Вийти'

    # admin checks edited user product from user account
    sign_in admin_user

    click_on 'Товари'
    expect(page).to have_content new_description
    expect(page).to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.warning'

    click_on user.account.name

    within('#product_0') do
      click_on 'Перевірено'
    end

    click_on 'Товари'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.info'
  end # when user creates/updates and admin checks a product

  scenario 'when admin creates/updates and admin checks a user product' do
    # admin creates a new user product
    sign_in admin_user

    click_on 'Користувачі'
    click_on user.account.name

    click_on 'Додати товар'
    fill_in 'product[title]', with: title
    fill_in 'product[description]', with: description
    
    expect { click_on 'Зберегти' }.to change(user.account.products, :count).by(1)
    expect(current_path).to eq account_path user.account
    expect(page).to have_content title
    expect(page).to have_content description
    expect(page).to have_link 'Видалити'
    expect(page).to have_link 'Перевірено'

    # admin checks a new user product from products list
    click_on 'Товари'
    expect(page).to have_selector 'tr.warning'
    
    click_on 'Перевірено'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.info'

    # admin updates a user product from products list -> pdoruct page
    click_on title

    click_on 'Редагувати'
    fill_in 'product[description]', with: new_description
    click_on 'Зберегти'

    expect(page).to have_content new_description

    click_on 'Товари'
    expect(page).to have_content new_description
    expect(page).to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.danger'

    click_on 'Перевірено'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.info'
  end # when admin creates/updates and admin checks a user product
end # Admin checks a product
