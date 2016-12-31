require_relative '../acceptance_helper'

feature 'Admin switch an user product visible', %q{
  Ad an admin
  I want to be able to switch an user product visible
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, visible: true) }
  let!(:product) { create :product, account: account }

  scenario 'when product visible' do
    visit root_path
    find('a.avatar').click

    expect(current_path).to eq account_path(account)
    expect(page).to have_content product.title
    expect(page).to have_content product.description
  end # when product visible

  scenario 'when admin switchs an user product visible' do    
    sign_in admin_user
    click_on 'Товари'

    expect(page).to have_link 'Приховувати'
    expect(page).not_to have_link 'Показувати'

    expect{ click_on 'Приховувати' }
      .to change { Product.find(product.id).visible }.from(true).to(false)
    expect(page).to have_link 'Показувати'
    expect(page).not_to have_link 'Приховувати'

    expect{ click_on 'Показувати' }
      .to change { Product.find(product.id).visible }.from(false).to(true)
    expect(page).to have_link 'Приховувати'
    expect(page).not_to have_link 'Показувати'
  end # when admin switchs an user product visible

  scenario 'when product invisible' do
    product.update_attribute(:visible, false)

    visit root_path
    find('a.avatar').click
    expect(page).not_to have_content product.title
    expect(page).not_to have_content product.description
  end # when product invisible
end # Admin switch an user product visible
