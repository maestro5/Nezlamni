require 'rails_helper'

feature 'Visitor buy', %q{
  As a visitor
  I want to be able to buy a product
} do
  
  let(:user) { create :user }
  let!(:product) { create :product, account: user.account }

  before do  
    user.account.toggle!(:visible)
  end

  scenario 'when visitor buys a product' do
    visit root_path
    find('a.avatar').click
    
    expect(current_path).to eq account_path(user.account)
    expect(page).to have_content product.title
    expect(page).to have_content product.description
    expect(page).to have_link 'Купити'

    click_on 'Купити'
    expect(current_path).to eq new_product_order_path(product)

    fill_in 'order[address]', with: 'test address'
    fill_in 'order[recipient]', with: 'John Galt'
    fill_in 'order[phone]', with: '+38(067)781-91-15'
    click_on 'Оформити'

    order = product.orders.first
    expect(page).to have_content product.title
    expect(page).to have_content order.recipient
    expect(page).to have_content order.phone
    expect(page).to have_content order.address
  end # when visitor buys a product
end # Visitor buy

feature 'Admin order in delivered', %q{
  As an admin
  I want to be able to switch order status in delivered
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create :user }
  let!(:product) { create :product, account: user.account }
  let!(:order) { create :order, product: product }

  scenario 'when admin switchs order status in delivered' do
    visit account_path(user.account)
    expect(page).to have_content 'Людей: 0'

    sign_in admin_user
    click_on 'Замовлення'
    
    expect(current_path).to eq orders_path
    expect(page).to have_link product.title
    expect(page).to have_content order.address
    expect(page).to have_content order.recipient
    expect(page).to have_content order.phone

    click_on 'Так'
    expect(page).not_to have_link 'Так'
    expect(page).to have_link 'Ні'

    visit account_path(user.account)
    expect(page).to have_content 'Людей: 1'
    
    click_on 'Замовлення'
    click_on 'Ні'
    expect(page).not_to have_link 'Ні'
    expect(page).to have_link 'Так'

    visit account_path(user.account)
    expect(page).to have_content 'Людей: 0'
  end # when admin switchs order status in delivered
end # Admin order in delivered