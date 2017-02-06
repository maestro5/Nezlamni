require_relative '../acceptance_helper'

feature 'Admin locks an account', %q{
  As an admin
  I want to be able to lock an account
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }

  scenario 'when admin locks user account' do
    sign_in admin_user
    click_on 'Збори'

    expect{ click_on 'Заблокувати' }
      .to change {Account.find(account.id).locked}.from(false).to(true)
    expect(page).to have_link 'Розблокувати'
    expect(page).not_to have_link 'Заблокувати'
  end

  context 'when user account locked' do
    before { account.update_attribute(:locked, true) }

    scenario 'when admin edit locked user account' do
      sign_in admin_user
      visit account_path account

      find('#edit_account').click
      fill_in 'account[name]', with: 'Dillan Garcia'

      expect{ click_on 'Зберегти' }.to change { Account.find(account.id).name }
      expect(page).to have_content 'Dillan Garcia'
    end

    scenario 'when admin edit locked user product' do      
      sign_in admin_user
      visit account_path account

      within '.product-default' do
        click_on 'Редагувати'
      end
      fill_in 'product[title]', with: 'admin edited product'

      click_on 'Зберегти'
      expect(page).to have_content 'admin edited product'
    end
  end # when user account locked
end # Admin locks an account

feature 'User locked account', %q{
  As an user
  I can not change a locked accoount and product
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user, locked: true) }

  scenario 'when user edit locked account' do
    # user can't edit locked account and can't add, edit, delete a product
    sign_in user
    click_on 'Збори'
    click_on account.name

    expect(page).not_to have_link 'Редагувати'
    expect(page).not_to have_link 'Додати товар'

    within '.product-default' do
      expect(page).not_to have_link 'Редагувати'
      expect(page).not_to have_link 'Видалити'
    end

    visit edit_account_path(account)
    expect(current_path).to eq root_path

    visit edit_product_path(account.products.first)
    expect(current_path).to eq root_path

    visit new_account_product_path(account)
    expect(current_path).to eq root_path
  end # when user edit locked account
end # User locked account