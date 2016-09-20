require_relative '../acceptance_helper'

feature 'Admin check account', %q{
  As a admin
  I want to be able to check an account
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let(:name) { 'user' }
  let(:goal) { 'Лікування' }
  let(:budget) { 100000 }
  
  scenario 'when admin checking new or changed account' do    
    # new account
    user.account.update_attribute(:name, name)

    sign_in admin_user
    click_on 'Користувачі'

    expect(page).to have_link name
    expect(page).to have_selector 'tr.warning'

    click_on 'Перевірено'
    expect(current_path).to eq accounts_path
    expect(page).to have_selector 'tr.danger'
    click_on 'Вийти'
    
    # user change account
    sign_in user
    click_on 'Моя сторінка'
    click_on 'Редагувати'
    fill_in 'account[goal]', with: goal
    click_on 'Зберегти'

    expect(current_path).to eq account_path user.account
    expect(page).not_to have_link 'Перевірено'

    click_on 'Вийти'

    # admin check changed account
    sign_in admin_user
    click_on 'Користувачі'

    expect(page).to have_content goal
    expect(page).to have_selector 'tr.info'

    click_on name
    expect(current_path).to eq account_path user.account
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Перевірено'

    click_on 'Перевірено'
    expect(current_path).to eq accounts_path
    expect(page).to have_selector 'tr.danger'

    # admin change account
    click_on name
    click_on 'Редагувати'
    fill_in 'account[budget]', with: budget
    click_on 'Зберегти'
    
    expect(current_path).to eq account_path user.account
    expect(page).to have_content budget
    click_on 'Користувачі'
    expect(page).to have_selector 'tr.info'
  end

end # Admin check account
