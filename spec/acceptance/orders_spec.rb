require 'rails_helper'

feature 'Visitor buy', %q{
  As a visitor
  I want to be able to buy a product
} do
  
  let(:user) { create :user }
  let(:account) { user.account }
  let!(:product) { create :product, account: account }

  before { account.toggle!(:visible) }

  scenario 'when a visitor click button [Підтримати цю дитину]' do
    visit root_path
    find('a.avatar').click
    click_on 'Підтримати цю дитину'

    expect(current_path).to eq account_products_path(account)
    within '#product_0' do
      expect(page).to have_content product.title
      expect(page).to have_content product.description
      expect(page).to have_content product.backers
      expect(page).to have_content product.remainder
    end
  end # when a visitor click button [Підтримати цю дитину]

  scenario 'when visitor supports a child with a reward' do
    # order
    visit root_path
    find('a.avatar').click   
    click_on 'Обрати'
    
    expect(current_path).to eq new_product_order_path(product)

    fill_in 'order[contribution]', with: 777
    fill_in 'order[email]', with: 'visitor@example.com'
    fill_in 'order[address]', with: 'test address'
    fill_in 'order[recipient]', with: 'Visitor Boldt'
    fill_in 'order[phone]', with: '+38(067)781-91-15'
    
    expect { click_on 'Оформити' }.to change(account.orders, :count).by(1)

    order = product.orders.first
    expect(current_path).to eq order_path(order)
    
    expect(page).to have_content product.title
    expect(page).to have_content order.recipient
    expect(page).to have_content order.phone
    expect(page).to have_content order.address

    # delivered
    sign_in user
    click_on 'Замовлення'
    expect(page).to have_selector 'tr.danger'
    expect(page).to have_link product.title
    expect(page).to have_content order.contribution
    expect(page).to have_content order.recipient
    expect(page).to have_content order.email
    expect(page).to have_content order.phone
    expect(page).to have_content order.address

    click_on 'Так'
    expect(page).to have_selector 'tr.success'
    expect(page).not_to have_selector 'tr.danger'

    visit account_path(account)
    expect(page).to have_content 1
    expect(page).to have_content 777
    within '#product_0' do
      expect(page).to have_content '12 людей, залишилось 8 з 20'
    end

    # canceled delivery
    click_on 'Замовлення'
    click_on 'Ні'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.success'

    visit account_path(account)
    expect(page).to have_content 0
    within '#product_0' do
      expect(page).to have_content '11 людей, залишилось 9 з 20'
    end
  end # when visitor supports a child with a reward
end # Visitor buy

feature 'Admin order in delivered', %q{
  As an admin
  I want to be able to switch order status in delivered
} do

  let(:admin_user) { create(:user_admin) }
  let(:user) { create :user }
  let!(:product) { create :product, account: user.account }
  let!(:order) { create :order, product: product, account: user.account }

  scenario 'when admin switchs order status in delivered' do
    visit account_path(user.account)
    expect(page).to have_content '0'

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
    expect(page).to have_content '1'
    
    click_on 'Замовлення'
    click_on 'Ні'
    expect(page).not_to have_link 'Ні'
    expect(page).to have_link 'Так'

    visit account_path(user.account)
    expect(page).to have_content '0'
  end # when admin switchs order status in delivered
end # Admin order in delivered