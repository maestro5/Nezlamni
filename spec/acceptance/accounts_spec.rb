require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor creates an account', %q{
  As a visitor
  I can't create an account
} do

  scenario 'when visitor creates an account' do
    visit root_path
    click_on 'Зібрати кошти'
    expect(current_path).to eq new_user_session_path
  end
end # Guest creates an account

# =====================================
# role: user
# =====================================
feature 'User creates an account', %q{
  As a user
  I want to be able to create an account
} do

  let(:user) { create(:user) }
  before { sign_in user }

  scenario 'when user creates an account' do
    click_on 'Зібрати кошти'

    fill_in 'account[name]', with: 'Bob Stark'
    fill_in 'account[goal]', with: 'Treatment'
    fill_in 'account[budget]', with: 37500
    fill_in 'account[deadline_on]', with: Time.now + 2.month
    fill_in 'account[birthday_on]', with: '21/05/2007'
    fill_in 'account[payment_details]', with: 'Delaware National Bank, account: 8190419'

    expect{click_on 'Зберегти'}.to change(Account, :count).by(+1)
  end # when user creates an account

  context 'when user has an account' do
    let!(:account) { create(:account, user: user) }
    scenario 'when user looks account list' do
      click_on 'Збори'

      expect(current_path).to eq accounts_path
      expect(page).to have_link account.name
      expect(page).to have_content account.goal
      expect(page).to have_content account.collected_percent

      expect(page).not_to have_link 'Перевірено'
      expect(page).not_to have_link 'Приховувати'
      expect(page).not_to have_link 'Перевірено'
      expect(page).not_to have_link 'Показувати'
      expect(page).not_to have_link 'Заблокувати'
      expect(page).not_to have_link 'Розблокувати'
      expect(page).not_to have_link 'Видалити'
    end # when user looks account list
  end
end # User creates an account

# =====================================
# role: admin
# =====================================
feature 'Admin creates an account', %q{
  As an admin
  I want to be able to create an account
} do

  let(:user_admin) { create(:user_admin) }
  
  scenario 'when admin creates an account' do
    sign_in user_admin
    click_on 'Зібрати кошти'
    
    fill_in 'account[name]', with: 'Bob Stark'
    fill_in 'account[goal]', with: 'Treatment'
    fill_in 'account[budget]', with: 37500
    fill_in 'account[deadline_on]', with: Time.now + 2.month
    fill_in 'account[birthday_on]', with: '21/05/2007'
    fill_in 'account[payment_details]', with: 'Delaware National Bank, account: 8190419'

    expect{click_on 'Зберегти'}.to change(Account, :count).by(+1)
  end # when admin creates an account
end # Admin creates an account
