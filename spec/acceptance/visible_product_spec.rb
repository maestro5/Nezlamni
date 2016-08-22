require 'rails_helper'

feature 'Admin switch an user product visible', %q{
  Ad an admin
  I want to be able to switch an user product visible
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let!(:product) { create :product, account: user.account }

  before { user.account.toggle!(:visible) }

  scenario 'when admin switchs an user product visible' do
    visit root_path
    find('a.avatar').click

    expect(current_path).to eq account_path(user.account)
    expect(page).to have_content product.title
    expect(page).to have_content product.description
    expect(page).to have_link 'Купити'

    sign_in admin_user
    click_on 'Товари'

    expect(page).not_to have_link 'Показувати'
    expect(page).to have_link 'Приховувати'
    
    click_on 'Приховувати'
    expect(page).not_to have_link 'Приховувати'
    expect(page).to have_link 'Показувати'

    click_on 'Вийти'

    visit root_path
    find('a.avatar').click
    expect(page).not_to have_content product.title
    expect(page).not_to have_content product.description
    expect(page).not_to have_link 'Купити'
  end # when admin switchs an user product visible
end # Admin switch an user product visible
