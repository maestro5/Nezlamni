require_relative '../acceptance_helper'

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
    within '.product' do
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
    expect(page).to have_content 'Дякуємо, за підтримку!'

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
    within '.product' do
      expect(page).to have_content '12 людей, залишилось 8 з 20'
    end

    # canceled delivery
    click_on 'Замовлення'
    click_on 'Ні'
    expect(page).to have_selector 'tr.danger'
    expect(page).not_to have_selector 'tr.success'

    visit account_path(account)
    expect(page).to have_content 0
    within '.product' do
      expect(page).to have_content '11 людей, залишилось 9 з 20'
    end
  end # when visitor supports a child with a reward
end # Visitor buy

feature 'User delivered', %q{
  As an user
  I want to be able to switch order status in delivered
} do

  let(:user) { create :user }
  let(:user_admin) { create(:user_admin) }
  let (:account_user) { user.account }
  let (:account_admin) { user_admin.account }
  let!(:product_user) { create :product, account: account_user, title: 'user product' }
  let!(:product_admin) { create :product, account: account_admin, title: 'admin product' }

  scenario 'show only user orders' do
    create_list :order, 5, product: product_user, account: account_user
    create_list :order, 5, product: product_admin, account: account_admin

    sign_in user
    visit orders_path
    expect(page).to have_link 'user product', count: 5
    expect(page).not_to have_link 'admin product'
  end

  scenario 'when switches order status in delivered' do
    order = create :order, product: product_user, account: account_user

    sign_in user
    visit orders_path
    expect(page).to have_link order.product.title
    expect(page).to have_content order.address
    expect(page).to have_content order.recipient
    expect(page).to have_content order.phone

    expect { click_on 'Так' }
      .to change { Account.find(account_user.id).backers }.by(1)
      .and change { Account.find(account_user.id).collected }.by(+777)
      .and change { Product.find(product_user.id).backers }.by(1)

    expect(page).not_to have_link 'Так'
    expect(page).to have_link 'Ні'

    expect { click_on 'Ні' }
      .to change { Account.find(account_user.id).backers }.by(-1)
      .and change { Account.find(account_user.id).collected }.by(-777)
      .and change { Product.find(product_user.id).backers }.by(-1)
    expect(page).not_to have_link 'Ні'
    expect(page).to have_link 'Так'
  end # when switches order status in delivered

  scenario 'pagination' do
    order = create :order, product: product_user, account: account_user

    sign_in user
    visit orders_path
    expect(page).to have_link order.product.title
    expect(page).not_to have_selector '.pagination'

    create_list :order, 13, product: product_user, account: account_user
    create_list :order, 5, product: product_admin, account: account_admin
    
    visit orders_path
    expect(page).to have_link order.product.title, count: 10
    
    within '.pagination' do
      click_on '2'
    end
    expect(page).to have_link order.product.title, count: 4

    within '.pagination' do
      click_on '1'
    end
    expect(page).to have_link order.product.title, count: 10
  end # pagination
end # User delivered

feature 'Admin delivered', %q{
  As an admin
  I want to be able to switch order status in delivered
} do

  let(:user_admin) { create(:user_admin) }
  let(:user) { create :user }
  let(:account_user) { user.account }
  let(:account_admin) { user_admin.account }
  let!(:product_user) { create :product, account: account_user }
  let!(:product_admin) { create :product, account: account_admin }
  let!(:order_user) { create :order, product: product_user, account: account_user }

  scenario 'when admin switches order status in delivered' do
    visit account_path(account_user)
    expect(page).to have_content '0'

    sign_in user_admin
    click_on 'Замовлення'
    
    expect(current_path).to eq orders_path
    expect(page).to have_link product_user.title
    expect(page).to have_content order_user.address
    expect(page).to have_content order_user.recipient
    expect(page).to have_content order_user.phone

    expect { click_on 'Так' }
      .to change { Account.find(account_user.id).backers }.by(1)
      .and change { Account.find(account_user.id).collected }.by(+777)
      .and change { Product.find(product_user.id).backers }.by(1)
    expect(page).not_to have_link 'Так'
    expect(page).to have_link 'Ні'

    visit account_path(account_user)
    expect(page).to have_content '1'
    
    click_on 'Замовлення'
    expect { click_on 'Ні' }
      .to change { Account.find(account_user.id).backers }.by(-1)
      .and change { Account.find(account_user.id).collected }.by(-777)
      .and change { Product.find(product_user.id).backers }.by(-1)
    expect(page).not_to have_link 'Ні'
    expect(page).to have_link 'Так'

    visit account_path(account_user)
    expect(page).to have_content '0'
  end # when admin switches order status in delivered

  scenario 'pagination' do
    create :order, product: product_admin, account: account_admin

    sign_in user_admin

    # show all orders
    visit orders_path
    expect(page).to have_link product_user.title, count: 2
    expect(page).not_to have_selector '.pagination'

    # pagination
    create_list :order, 13, product: product_user, account: account_user
    create_list :order, 7, product: product_admin, account: account_admin
    
    visit orders_path
    expect(page).to have_link product_user.title, count: 10
    
    within '.pagination' do
      click_on '2'
    end
    expect(page).to have_link product_user.title, count: 10

    within '.pagination' do
      click_on '3'
    end
    expect(page).to have_link product_user.title, count: 2

    within '.pagination' do
      click_on '1'
    end
    expect(page).to have_link product_user.title, count: 10
  end # pagination
end # Admin delivered