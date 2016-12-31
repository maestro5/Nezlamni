require_relative '../acceptance_helper'

feature 'User account and product images', %q{
  As a user
  I want to be able to upload account and product images, set avatar
} do

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, visible: true) }
  let!(:product) { create :product, account: account }

  # before { user.account.toggle!(:visible) }

  scenario 'when user uploads account image and set account avatar' do
    sign_in user
    visit account_path(account)

    find('#edit_account').click
    attach_file('image[image]', 'spec/test.jpg')
    
    expect { click_on 'Додати' }.to change(account.images, :count).by(1)
    expect(current_path).to eq edit_account_path(account)
    expect(page).to have_css("img[src*='test.jpg']")
    
    # avatar
    within('.avatar') do
      expect(page).not_to have_css("img[src*='test.jpg']")  
    end

    find('.avatar').click
    expect(current_path).to eq account_images_path(account)

    within('#images') do
      first('a').click
    end

    expect(current_path).to eq edit_account_path(account)
    expect(page).to have_css("img[src*='test.jpg']")
    within('.avatar') do
      expect(page).to have_css("img[src*='test.jpg']")
    end

    visit account_path(account)
    expect(page).to have_css("img[src*='test.jpg']")
    within('.avatar') do
      expect(page).to have_css("img[src*='test.jpg']")
    end

    visit root_path
    expect(page).to have_css("img[src*='test.jpg']")
  end # when user uploads account image and set account avatar

  scenario 'when user uploads product image and set product avatar' do
    sign_in user
    visit account_path(account)

    within all('.product').last do
      click_on 'Редагувати'
    end

    attach_file('image[image]', 'spec/test.jpg')
    
    expect { click_on 'Додати' }.to change(product.images, :count).by(1)
    expect(current_path).to eq edit_product_path(product)
    expect(page).to have_css("img[src*='test.jpg']")
    
    # avatar
    within('.product_avatar') do
      expect(page).not_to have_css("img[src*='test.jpg']")  
    end

    find('.product_avatar').click
    expect(current_path).to eq product_images_path(product)

    within('#images') do
      first('a').click
    end

    expect(current_path).to eq edit_product_path(product)
    expect(page).to have_css("img[src*='test.jpg']")
    within('.product_avatar') do
      expect(page).to have_css("img[src*='test.jpg']")  
    end

    visit account_path(account)
    expect(page).to have_css("img[src*='test.jpg']")
  end # when user uploads product image and set product avatar
end # User account and product images
