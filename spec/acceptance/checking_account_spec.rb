require_relative '../acceptance_helper'

feature 'Admin check account', %q{
  As an admin
  I want to be able to check an account
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }

  scenario 'when admin checking new account' do
    sign_in admin_user
    click_on 'Збори'

    expect(page).to have_link account.name
    expect(page).to have_selector 'tr.warning'

    click_on 'Перевірено'
    expect(current_path).to eq accounts_path
    expect(page).to have_selector 'tr.danger'
  end # when admin checking new account

  scenario 'when admin checking changed account' do
    # user change account
    sign_in user
    visit account_path account
    find('#edit_account').click
    fill_in 'account[goal]', with: 'Лікування'
    click_on 'Зберегти'

    expect(current_path).to eq account_path account
    expect(page).not_to have_link 'Перевірено'

    click_on 'Вийти'

    # admin check changed account
    sign_in admin_user
    click_on 'Збори'
    expect(page).to have_content 'Лікування'
    expect(page).to have_selector 'tr.info'

    click_on account.name
    expect(current_path).to eq account_path account
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Перевірено'

    find('#check_account').click
    expect(current_path).to eq accounts_path
    expect(page).to have_selector 'tr.danger'    
  end # when admin checking changed account

  scenario 'when admin changed and checking account' do
    # admin change account
    sign_in admin_user
    click_on 'Збори'
    click_on account.name
    find('#edit_account').click
    fill_in 'account[budget]', with: 10000
    click_on 'Зберегти'

    expect(current_path).to eq account_path account
    expect(page).to have_content 10000
    click_on 'Збори'
    expect(page).to have_selector 'tr.info'

    click_on 'Перевірено'
    expect(current_path).to eq accounts_path
    expect(page).to have_selector 'tr.danger'
  end # when admin changed and checking account
end # Admin check account
