require_relative '../acceptance_helper'

feature 'Admin switch an user account visible', %q{
  As an admin
  I want to be able to switch an user account visible
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }

  scenario 'when admin switchs an user account visible' do
    user.account.update_attribute(:name, 'user')

    visit root_path
    expect(page).not_to have_link user.account.name

    sign_in admin_user
    click_on 'Користувачі'
    click_on 'Показувати'

    visit root_path
    expect(page).to have_link user.account.name

    click_on 'Користувачі'
    click_on 'Приховувати'

    visit root_path
    expect(page).not_to have_link user.account.name
  end # when admin switchs an user account visible
end # Admin switch an user account visible