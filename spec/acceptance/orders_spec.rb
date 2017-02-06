require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor buy', %q{
  As a visitor
  I want to be able to buy a product
} do
  
  let(:user)     { create :user }
  let(:account)  { create :account, user: user, visible: true }
  let!(:product) { create :product, account: account }

  before do
    visit root_path
    find('a.avatar').click
  end

  scenario 'when a visitor click button [Підтримати цю дитину]' do
    click_on 'Підтримати цю людину'
    expect(current_path).to eq account_products_path(account)
    within all('.product').last do
      expect(page).to have_content product.title
      expect(page).to have_content product.description
      expect(page).to have_content product.backers
      expect(page).to have_content product.remainder
    end
  end # when a visitor click button [Підтримати цю дитину]

  scenario 'when visitor supports a child with a reward' do
    within all('.product').last do
      click_on 'Обрати'
    end
    expect(current_path).to eq new_product_order_path(product)

    fill_in 'order[contribution]', with: 777
    fill_in 'order[email]', with: 'visitor@example.com'
    fill_in 'order[address]', with: 'test address'
    fill_in 'order[recipient]', with: 'Visitor Boldt'
    fill_in 'order[phone]', with: '+38(067)781-91-15'
    expect { click_on 'Оформити' }.to change(account.orders, :count).by(1)

    expect(current_path).to eq order_path(Order.last)
    expect(page).to have_content 'Дякуємо, за підтримку!'
  end # when visitor supports a child with a reward
end # Visitor buy

# =====================================
# role: user
# =====================================
feature 'User delivered', %q{
  As an user
  I want to be able to switch order status in delivered
} do

  let(:user_one)    { create :user }
  let(:user_two)    { create :user }
  let(:account_one) { create :account, user: user_one }
  let(:account_two) { create :account, user: user_two }
  let(:product_one) { create :product, account: account_one, title: 'user one product' }
  let(:product_two) { create :product, account: account_two, title: 'user two product' }

  before { sign_in user_one }

  scenario 'show only user orders' do
    create_list :order, 5, product: product_one, account: account_one
    create_list :order, 5, product: product_two, account: account_two

    visit orders_path
    expect(page).to have_link 'user one product', count: 5
    expect(page).not_to have_link 'user two product'
  end

  context 'when order exist' do
    let!(:order) { create :order, product: product_one, account: account_one }

    scenario 'when switches order status in delivered' do
      visit orders_path
      expect(page).to have_link order.product.title
      expect(page).to have_content order.address
      expect(page).to have_content order.recipient
      expect(page).to have_content order.phone

      expect { click_on 'Так' }
        .to change { Account.find(account_one.id).backers }.by(1)
        .and change { Account.find(account_one.id).collected }.by(+777)
        .and change { Product.find(product_one.id).backers }.by(1)
      expect(page).not_to have_link 'Так'
      expect(page).to have_link 'Ні'
    end # when switches order status in delivered

    scenario 'when switches order status in undelivered' do
      order.update_attribute(:delivered, true)

      visit orders_path
      expect(page).to have_link order.product.title
      expect(page).to have_content order.address
      expect(page).to have_content order.recipient
      expect(page).to have_content order.phone

      expect { click_on 'Ні' }
        .to change { Account.find(account_one.id).backers }.by(-1)
        .and change { Account.find(account_one.id).collected }.by(-777)
        .and change { Product.find(product_one.id).backers }.by(-1)
      expect(page).to have_link 'Так'
      expect(page).not_to have_link 'Ні'
    end # when switches order status in undelivered
  end # when order exist

  scenario 'when select another page in pagination' do
    visit orders_path
    expect(page).not_to have_selector '.pagination'

    create_list :order, 13, product: product_one, account: account_one
    create_list :order, 5,  product: product_two, account: account_two
    
    visit orders_path
    expect(page).to have_link product_one.title, count: 10
    
    within '.pagination' do
      click_on '2'
    end
    expect(page).to have_link product_one.title, count: 3

    within '.pagination' do
      click_on '1'
    end
    expect(page).to have_link product_one.title, count: 10
  end # pagination
end # User delivered

# =====================================
# role: admin
# =====================================
feature 'Admin delivered', %q{
  As an admin
  I want to be able to switch order status in delivered
} do

  let(:user_admin) { create :user_admin }
  let(:user)       { create :user }
  let(:account)    { create :account, user: user, visible: true }
  let(:product)    { create :product, account: account }
  let!(:order)     { create :order, product: product, account: account }

  before { sign_in user_admin }

  scenario 'when admin switches order status in delivered' do
    visit account_path(account)
    within '.backers' do
      expect(page).to have_content '0'
    end

    click_on 'Замовлення'    
    expect(current_path).to eq orders_path
    expect(page).to have_link product.title
    expect(page).to have_content order.address
    expect(page).to have_content order.recipient
    expect(page).to have_content order.phone
    expect { click_on 'Так' }
      .to change { Account.find(account.id).backers }.by(1)
      .and change { Account.find(account.id).collected }.by(+777)
      .and change { Product.find(product.id).backers }.by(1)
    expect(page).not_to have_link 'Так'
    expect(page).to have_link 'Ні'

    visit account_path(account)
    within '.backers' do
      expect(page).to have_content '1'
    end
  end # when admin switches order status in delivered

  scenario 'when admin switches order status in undelivered' do
    order.update_attribute(:delivered, true)

    visit account_path(account)
    within '.backers' do
      expect(page).to have_content '1'
    end
    
    click_on 'Замовлення'
    expect { click_on 'Ні' }
      .to change { Account.find(account.id).backers }.by(-1)
      .and change { Account.find(account.id).collected }.by(-777)
      .and change { Product.find(product.id).backers }.by(-1)
    expect(page).not_to have_link 'Ні'
    expect(page).to have_link 'Так'

    visit account_path(account)
    expect(page).to have_content '0'
  end # when admin switches order status in delivered
end # Admin delivered
