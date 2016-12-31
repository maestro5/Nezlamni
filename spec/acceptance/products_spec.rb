require_relative '../acceptance_helper'

# =====================================
# role: user
# =====================================
feature 'User add product', %q{
  As an user
  I want to be able to add a product
} do

  let(:user) { create :user }
  let(:account) { create(:account, user: user) }

  before { account.toggle!(:visible) }

  scenario 'when user add a new product' do
    sign_in user

    visit account_path account
    click_on 'Додати товар'
    expect(current_path).to eq new_account_product_path(account)

    fill_in 'product[contribution]', with: 100
    fill_in 'product[title]', with: 'Тестовий товар'
    fill_in 'product[description]', with: 'Опис тестового товара'
    fill_in 'product[backers]', with: 11
    fill_in 'product[remainder]', with: 20

    expect { click_on 'Зберегти' }.to change(account.products, :count).by(1)

    expect(current_path).to eq account_path(account)
    within all('.product').last do
      expect(page).to have_content 'Внесок 100.0 грн. або більше'
      expect(page).to have_link 'Тестовий товар'
      expect(page).to have_content 'Опис тестового товара'
      expect(page).to have_content '11 людей, залишилось 9 з 20'
    end
  end # when user add a new product
end # User add a product

feature 'User change a product', %q{
  As an user
  I want to be able to change a product
} do

  let(:user) { create :user }
  let(:account) { create(:account, user: user) }
  let!(:product) { create :product, account: account }
  
  before { account.toggle!(:visible) }

  scenario 'when user change a product' do
    sign_in user

    visit account_path account
    within all('.product').last do
      click_on 'Редагувати'
    end

    expect(current_path).to eq edit_product_path(product)

    # contribution
    fill_in 'product[contribution]', with: 0
    click_on 'Зберегти'

    expect(current_path).to eq account_path(account)
    within all('.product').last do
      expect(page).not_to have_content 'Внесок'
      click_on 'Редагувати'
    end

    fill_in 'product[contribution]', with: 333
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content 'Внесок 333.0 грн. або більше'
      click_on 'Редагувати'
    end

    # contributions_stat
    fill_in 'product[backers]', with: 7
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей, залишилось 13 з 20'
      click_on 'Редагувати'
    end

    fill_in 'product[remainder]', with: 30
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей, залишилось 23 з 30'
      click_on 'Редагувати'
    end

    fill_in 'product[remainder]', with: 0
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей'
      click_on 'Редагувати'
    end

    fill_in 'product[backers]', with: 0
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).not_to have_content 'людей'
    end
  end # when user change a product
end # User change a product

# =====================================
# role: admin
# =====================================
feature 'Admin add product', %q{
  As an admin
  I want to be able to add a product
} do

  let(:user_admin) { create :user_admin }
  let(:user) { create :user }
  let(:account) { create(:account, user: user) }

  before { account.toggle!(:visible) }

  scenario 'when admin add a new product' do
    sign_in user_admin

    visit account_path account
    click_on 'Додати товар'
    expect(current_path).to eq new_account_product_path(account)

    fill_in 'product[contribution]', with: 100
    fill_in 'product[title]', with: 'Тестовий товар'
    fill_in 'product[description]', with: 'Опис тестового товара'
    fill_in 'product[backers]', with: 11
    fill_in 'product[remainder]', with: 20

    expect { click_on 'Зберегти' }.to change(account.products, :count).by(1)

    expect(current_path).to eq account_path(account)
    within all('.product').last do
      expect(page).to have_content 'Внесок 100.0 грн. або більше'
      expect(page).to have_link 'Тестовий товар'
      expect(page).to have_content 'Опис тестового товара'
      expect(page).to have_content '11 людей, залишилось 9 з 20'
      expect(page).to have_link 'Редагувати'
      expect(page).to have_link 'Видалити'
      expect(page).to have_link 'Перевірено'
      expect(page).to have_link 'Обрати'
    end
  end # when user add a new product
end # Admin add a product

feature 'Admin change a product', %q{
  As an admin
  I want to be able to change a product
} do

  let(:user_admin) { create :user_admin }
  let(:user) { create :user }
  let(:account) { create(:account, user: user) }
  let!(:product) { create :product, account: account }
  
  before { account.toggle!(:visible) }

  scenario 'when admin change a product' do
    sign_in user_admin

    visit account_path account
    within all('.product').last do
      click_on 'Редагувати'
    end

    expect(current_path).to eq edit_product_path(product)

    # contribution
    fill_in 'product[contribution]', with: 0
    click_on 'Зберегти'

    expect(current_path).to eq account_path(account)
    within all('.product').last do
      expect(page).not_to have_content 'Внесок'
      click_on 'Редагувати'
    end

    fill_in 'product[contribution]', with: 333
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content 'Внесок 333.0 грн. або більше'
      click_on 'Редагувати'
    end

    # contributions_stat
    fill_in 'product[backers]', with: 7
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей, залишилось 13 з 20'
      click_on 'Редагувати'
    end

    fill_in 'product[remainder]', with: 30
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей, залишилось 23 з 30'
      click_on 'Редагувати'
    end

    fill_in 'product[remainder]', with: 0
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).to have_content '7 людей'
      click_on 'Редагувати'
    end

    fill_in 'product[backers]', with: 0
    click_on 'Зберегти'
    within all('.product').last do
      expect(page).not_to have_content 'людей'
    end
  end # when admin change a product
end # Admin change a product
