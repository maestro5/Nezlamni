require_relative '../acceptance_helper'

feature 'Admin checks a product', %q{
  As a admin
  I want to be able to check a product
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:product) { create(:product, account: account) }
  let(:new_description) { 'new product description' }
  
  scenario 'when user creates and admin checks a product' do
    # user not available to check a product
    sign_in user
    visit account_path(account)
    expect(current_path).to eq account_path account
    within all('.product').last do
      expect(page).to have_link 'Редагувати'
      expect(page).to have_link 'Видалити'
      expect(page).not_to have_link 'Перевірено'
    end
    click_on 'Вийти'

    # admin checks a new product from product page
    sign_in admin_user
    click_on 'Товари'
    expect(page).to have_selector 'tr.warning'

    click_on product.title
    click_on 'Перевірено'
    click_on 'Товари'
    expect(page).not_to have_selector 'tr.warning'
    expect(page).not_to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.danger'
  end

  scenario 'when user changes a product and admin checks a product' do
    # user updates a product
    sign_in user
    visit edit_product_path(product)    
    fill_in 'product[description]', with: new_description
    click_on 'Зберегти'
    click_on 'Вийти'

    # admin checks edited user product from user account
    sign_in admin_user
    click_on 'Товари'
    expect(page).to have_content new_description
    expect(page).to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.warning'

    click_on account.name
    within all('.product').last do
      click_on 'Перевірено'
    end

    click_on 'Товари'
    expect(page).not_to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.warning'
    expect(page).not_to have_selector 'tr.danger'
  end # when user creates/updates and admin checks a product

  scenario 'when admin updates and checks a user product' do
    sleep 1
    product.update_attribute(:was_changed, false)

    sign_in admin_user
    click_on 'Товари'
    expect(page).not_to have_selector 'tr.warning'
    expect(page).not_to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.danger'

    click_on product.title
    click_on 'Редагувати'
    fill_in 'product[description]', with: new_description
    click_on 'Зберегти'
    expect(current_path).to eq account_path account
    expect(page).to have_content new_description

    click_on 'Товари'
    expect(page).to have_content new_description
    expect(page).to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.warning'

    click_on 'Перевірено'
    expect(page).not_to have_selector 'tr.info'
    expect(page).not_to have_selector 'tr.warning'
    expect(page).not_to have_selector 'tr.danger'
  end # when admin creates/updates and checks a user product
end # Admin checks a product
