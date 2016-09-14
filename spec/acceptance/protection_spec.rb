require_relative '../acceptance_helper'

# ---------------------------------
# Visitor
# ---------------------------------
feature 'Visitor close routes and links', %q{
  As a visitor
  I want to not be available to User and Admin links
} do

  let(:user) { create :user }
  let(:account) { user.account }
  let!(:product) { create :product, account: account }
  let!(:article) { create :article, account: account }
  let(:order) { create :order, product: product }

  scenario 'menu items' do
    visit root_path
    expect(page).to have_link 'Реєстрація'
    expect(page).to have_link 'Увійти'
    expect(page).not_to have_link 'Моя сторінка'
    expect(page).not_to have_link 'Замовлення'
    expect(page).not_to have_link 'Користувачі'
    expect(page).not_to have_link 'Товари'
    expect(page).not_to have_link 'Новини'
    expect(page).not_to have_link 'Вийти'
  end # menu items

  context 'home page, accounts and articles' do
    scenario 'when default user account' do
      visit root_path
      expect(page).not_to have_css '.article'
      expect(page).not_to have_css 'a.avatar'
    end

    scenario 'when visible user account' do
      # default user article
      account.update_attribute(:visible, true)
      visit root_path
      expect(page).to have_css '.article'
      expect(page).to have_css 'a.avatar'

      # invisible user article
      article.update_attribute(:visible, false)
      visit root_path
      expect(page).not_to have_css '.article'
      expect(page).to have_css 'a.avatar'
    end # visible user account
  end # home page, accounts and articles

  scenario 'article page' do
    account.update_attribute(:visible, true)
    visit root_path
    within '.article' do
      click_on article.title
    end
    expect(page).not_to have_link 'Редагувати'
    expect(page).not_to have_link 'Видалити'
  end # article page

  scenario 'when account default (invisible)' do
    visit account_path(account)
    expect(current_path).to eq root_path
  end

  context 'account page when user account visible' do
    before { account.update_attribute(:visible, true) }
    before { visit account_path(account) }

    scenario 'not have acount links' do
      expect(page).not_to have_selector '#edit_account'
      expect(page).not_to have_link 'Перевірено'
    end

    scenario 'when product default' do
      expect(page).not_to have_link 'Додати товар'
      within '#product_0' do
        expect(page).not_to have_link 'Редагувати'
        expect(page).not_to have_link 'Видалити'
        expect(page).not_to have_link 'Перевірено'
        expect(page).to have_link 'Обрати'
      end

      # support child
      click_on 'Підтримати цю дитину'
      expect(page).not_to have_link 'Додати товар'
      within '#product_0' do
        expect(page).not_to have_link 'Редагувати'
        expect(page).not_to have_link 'Видалити'
        expect(page).not_to have_link 'Перевірено'
        expect(page).to have_link 'Обрати'
      end
    end # when product default

    scenario 'product invisible' do
      product.update_attribute(:visible, false)
      visit account_path(account)
      expect(page).not_to have_link 'Додати товар'
      expect(page).not_to have_css '#product_0'

      # account support child
      click_on 'Підтримати цю дитину'
      expect(page).not_to have_link 'Додати товар'
      expect(page).not_to have_css '#product_0'
    end # when product invisible
  
    scenario 'when article default' do
      visit account_path(account)
      within '.section-tabs' do
        click_on 'Новини'
        expect(page).not_to have_link 'Додати'

        within '.article' do
          expect(page).to have_link article.title
          expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
          expect(page).to have_link 'Детальніше ...' 
          expect(page).not_to have_link 'Редагувати'
          expect(page).not_to have_link 'Видалити'

          click_on article.title
        end
        expect(current_path).to eq article_path(article)
      end # .section-tabs
    end # when article default

    scenario 'when article invisible' do
      article.update_attribute(:visible, false)
      visit account_path(account)
      within '.section-tabs' do
        click_on 'Новини'
        expect(page).not_to have_link 'Додати'
        expect(page).not_to have_selector '.article'
      end # .section-tabs
    end # when article invisible
  end # account page when user account visible
end # Visitor close routes and links

# ---------------------------------
# User
# ---------------------------------
feature 'User close routes and links', %q{
  As a user
  I want to not be available to close User and Admin links
} do

  let(:user) { create :user }
  let(:user_admin) { create :user_admin }
  let(:account_admin) { user_admin.account }
  let(:account_user) { user.account }
  let(:product_user) { create :product, account: account_user }
  let(:product_admin) { create :product, account: account_admin }
  let!(:article_user) { create :article, account: account_user }
  let(:article_admin) { create :article, account: account_admin }
  let!(:order_user) { create :order, product: product_user, account: account_user }

  scenario 'menu items' do
    sign_in user
    expect(page).to have_link 'Моя сторінка'
    expect(page).to have_link 'Замовлення'
    expect(page).not_to have_link 'Користувачі'
    expect(page).not_to have_link 'Товари'
    expect(page).not_to have_link 'Новини'
    expect(page).to have_link 'Вийти'
  end # menu items

  context 'home page, avatars and articles' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        scenario 'when article visible (default)' do
          visit root_path
          if account_user.visible?
            expect(page).to have_css 'a.avatar'
            expect(page).to have_css '.article'            
          else
            expect(page).not_to have_css 'a.avatar'
            expect(page).not_to have_css '.article'
          end # account visible?
        end # when article visible (default)

        scenario 'when article invisible' do
          article_user.update_attribute(:visible, false)
          visit root_path
          if account_user.visible?
            expect(page).to have_css 'a.avatar'
          else
            expect(page).not_to have_css 'a.avatar'
          end
          expect(page).not_to have_css '.article'
        end # when article invisible
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # home page, accounts and articles

  context 'orders page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }
        before { click_on 'Замовлення' }

        scenario 'when product visible (default)' do
          expect(page).to have_selector 'tr.danger'
          expect(page).to have_link 'Так'
          expect(page).not_to have_link 'Ні'
          
          unless account_user.locked?
            click_on 'Так'
            expect(page).to have_selector 'tr.success'
            expect(page).to have_link 'Ні'
            expect(page).not_to have_link 'Так'
          end
        end # when product visible (default)

        scenario 'when product invisible' do
          product_user.update_attribute(:visible, false)
          expect(page).to have_selector 'tr.danger'
          expect(page).to have_link 'Так'
          expect(page).not_to have_link 'Ні'
          unless account_user.locked?
            click_on 'Так'
            expect(page).to have_selector 'tr.success'
            expect(page).to have_link 'Ні'
            expect(page).not_to have_link 'Так'
          end
        end # when product invisible
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # my orders page

  context 'account page, account actions' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        scenario 'available links' do
          visit account_path(account_user)
          expect(current_path).to eq account_path(account_user)
          if account_user.locked?
            expect(page).not_to have_selector '#edit_account'
            expect(page).not_to have_link 'Видалити'
          else
            expect(page).to have_selector '#edit_account'
            expect(page).to have_link 'Видалити'

            find('#edit_account').click
            expect(current_path).to eq edit_account_path(account_user)
            expect(page).to have_button 'Зберегти'
          end # account_user.locked?
        end # available links

        scenario 'when user on someone else\'s account page' do
          account_admin.update_attribute(:visible, true)
          visit account_path(account_admin)
          expect(current_path).to eq account_path(account_admin)
          expect(page).not_to have_selector '#edit_account'
          expect(page).not_to have_link 'Видалити'
        end # when user on someone else\'s account page
      end # user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # account page, account actions

  context 'account page, product actions' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        context 'when product visible (default)' do
          scenario 'actions' do
            visit account_path(account_user)
            if account_user.locked?
              expect(page).not_to have_link 'Додати товар'
              within '#product_0' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account_user.visible?
                click_on 'Обрати' if account_user.visible?
              end
              if account_user.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end

              visit account_path(account_user)
              click_on 'Підтримати цю дитину'
              expect(current_path).to eq account_products_path(account_user)
              expect(page).not_to have_link 'Додати товар'
              within '#product_0' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account_user.visible?
                click_on 'Обрати' if account_user.visible?
              end
              if account_user.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end
            else
              expect(page).to have_link 'Додати товар'
              within '#product_0' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account_user.visible?
                click_on 'Обрати' if account_user.visible?
              end
              if account_user.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end

              visit account_path(account_user)
              click_on 'Підтримати цю дитину'
              expect(page).to have_link 'Додати товар'
              within '#product_0' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account_user.visible?
                click_on 'Обрати' if account_user.visible?                  
              end
              if account_user.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end
            end # account_user.locked?
          end # product actions

          scenario 'when user on someone else\'s account page' do
            product_admin
            account_admin.update_attribute(:visible, true)
            visit account_path(account_admin)

            expect(current_path).to eq account_path(account_admin)
            expect(page).not_to have_link 'Додати товар'
            within '#product_0' do
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
              expect(page).not_to have_link 'Перевірено'
              click_on 'Обрати'
            end
            expect(current_path).to eq new_product_order_path(product_admin)
            expect(page).to have_button 'Оформити'

            visit account_path(account_admin)
            click_on 'Підтримати цю дитину'
            expect(current_path).to eq account_products_path(account_admin)
            expect(page).not_to have_link 'Додати товар'
            within '#product_0' do
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
              expect(page).not_to have_link 'Перевірено'
              click_on 'Обрати'
            end
            expect(current_path).to eq new_product_order_path(product_admin)
            expect(page).to have_button 'Оформити'
          end # when user on someone else\'s account page
        end # when product visible (default)

        context 'when product invisible' do
          scenario 'actions' do
            product_user.update_attribute(:visible, false)
            visit account_path(account_user)
            
            if account_user.locked?
              expect(page).not_to have_link 'Додати товар'
              within '#product_0' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати'
              end
              click_on 'Підтримати цю дитину'
              expect(page).not_to have_link 'Додати товар'
              within '#product_0' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати'
              end
            else
              expect(page).to have_link 'Додати товар'
              within '#product_0' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати'
              end
              click_on 'Підтримати цю дитину'
              expect(page).to have_link 'Додати товар'
              within '#product_0' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати'
              end
            end # account_user.locked?
          end # product actions

          scenario 'when user visit someone else\'s account page' do
            account_admin.update_attribute(:visible, true)
            product_admin.update_attribute(:visible, false)
            visit account_path(account_admin)

            expect(current_path).to eq account_path(account_admin)
            expect(page).not_to have_link 'Додати товар'
            expect(page).not_to have_selector '#product_0'
          
            click_on 'Підтримати цю дитину'
            expect(page).not_to have_link 'Додати товар'
            expect(page).not_to have_selector '#product_0'
          end # when user on someone else\'s account page
        end # when product invisible
      end # when user account visible? locked?  
    end # generate user account parameters (visible, locked)
  end # account page, product actions

  context 'account page, article actions' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        context 'when article visible (default)' do
          scenario 'actions' do
            visit account_path(account_user)
            expect(current_path).to eq account_path(account_user)

            if account_user.locked?
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).not_to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'Детальніше ...' 
                  expect(page).not_to have_link 'Редагувати'
                  expect(page).not_to have_link 'Видалити'
                  click_on article_user.title
                end
              end # .section-tabs
              expect(current_path).to eq article_path(article_user)
              expect(page).to have_content article_user.title
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
            else
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'Детальніше ...' 
                  expect(page).to have_link 'Редагувати'
                  expect(page).to have_link 'Видалити'
                  click_on article_user.title
                end
              end # .section-tabs
              expect(current_path).to eq article_path(article_user)
              expect(page).to have_content article_user.title
              expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
              expect(page).to have_link 'Редагувати'
              expect(page).to have_link 'Видалити'
            end # account_user.locked?
          end # actions

          scenario 'when user on someone else\'s account page' do
            account_admin.update_attribute(:visible, true)
            article_admin
            visit account_path(account_admin)
            expect(current_path).to eq account_path(account_admin)
            within '.section-tabs' do
              click_on 'Новини'
              expect(page).not_to have_link 'Додати'
              within '.article' do
                expect(page).to have_link article_admin.title
                expect(page).to have_css('a[href=\'' + article_path(article_admin) + '\']')
                expect(page).to have_link 'Детальніше ...' 
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                click_on article_admin.title
              end
            end # .section-tabs
            expect(current_path).to eq article_path(article_admin)
            expect(page).to have_content article_admin.title
            expect(page).not_to have_link 'Редагувати'
            expect(page).not_to have_link 'Видалити'
          end # when user on someone else\'s account page
        end # when article visible (default)

        context 'when article invisible' do
          scenario 'actions' do
            article_user.update_attribute(:visible, false)
            visit account_path(account_user)
            expect(current_path).to eq account_path(account_user)

            if account_user.locked?
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).not_to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'Детальніше ...' 
                  expect(page).not_to have_link 'Редагувати'
                  expect(page).not_to have_link 'Видалити'
                  click_on article_user.title
                end
              end # .section-tabs
              expect(current_path).to eq article_path(article_user)
              expect(page).to have_content article_user.title
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
            else
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'Детальніше ...' 
                  expect(page).to have_link 'Редагувати'
                  expect(page).to have_link 'Видалити'
                  click_on article_user.title
                end
              end # .section-tabs
              expect(current_path).to eq article_path(article_user)
              expect(page).to have_content article_user.title
              expect(page).to have_link 'Редагувати'
              expect(page).to have_link 'Видалити'
            end # account_user.locked?
          end # actions

          scenario 'when user visit someone else\'s account page' do
            account_admin.update_attribute(:visible, true)
            article_admin.update_attribute(:visible, false)
            
            visit account_path(account_admin)
            expect(current_path).to eq account_path(account_admin)
            within '.section-tabs' do
              click_on 'Новини'
              expect(page).not_to have_link 'Додати'
              expect(page).not_to have_selector '.article'
            end # .section-tabs
          end # when user on someone else\'s account page
        end # when article invisible
      end # when user account visible? locked
    end # generate user account parameters (visible, locked)
  end # account page, article actions
end # User close routes and links

feature 'Admin routes and links', %q{
  As an admin
  I want to be available to all routes and links
} do

  let(:user) { create :user }
  let(:user_admin) { create :user_admin }
  let(:account_admin) { user_admin.account }
  let(:account_user) { user.account }
  let!(:product_user) { create :product, account: account_user }
  let!(:product_admin) { create :product, account: account_admin }
  let!(:article_user) { create :article, account: account_user }
  let(:article_admin) { create :article, account: account_admin }
  let!(:order_user) { create :order, product: product_user, account: account_user }
  let!(:order_admin) { create :order, product: product_admin, account: account_admin }

  scenario 'menu items' do
    sign_in user_admin
    expect(page).to have_link 'Моя сторінка'
    expect(page).to have_link 'Замовлення'
    expect(page).to have_link 'Користувачі'
    expect(page).to have_link 'Товари'
    expect(page).to have_link 'Новини'
    expect(page).to have_link 'Вийти'
  end # menu items

  context 'home page, avatars and articles' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { article_user }
        before { sign_in user_admin }

        scenario 'when article visible (default)' do
          visit root_path
          if account_user.visible?
            expect(page).to have_css 'a.avatar'
            expect(page).to have_css '.article'            
          else
            expect(page).not_to have_css 'a.avatar'
            expect(page).not_to have_css '.article'
          end # account visible?
        end # when article visible (default)

        scenario 'when article invisible' do
          article_user.update_attribute(:visible, false)
          visit root_path
          if account_user.visible?
            expect(page).to have_css 'a.avatar'
          else
            expect(page).not_to have_css 'a.avatar'
          end
          expect(page).not_to have_css '.article'
        end # when article invisible
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # home page, accounts and articles

  context 'orders page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user_admin }
        before { click_on 'Замовлення' }

        scenario 'when product visible (default)' do
          expect(page).to have_selector 'tr.danger', count: 2
          expect(page).to have_link 'Так', count: 2
          expect(page).not_to have_link 'Ні'
          expect(order_admin.delivered).to be false
          expect(order_admin.delivered).to be false
          
          first(:link, 'Так').click
          order_admin.reload
          expect(order_admin.delivered).to be true
          expect(order_user.delivered).to be false
          expect(page).to have_selector 'tr.success'
          expect(page).to have_selector 'tr.danger'
          expect(page).to have_link 'Ні'
          expect(page).to have_link 'Так'

          click_on 'Так'
          order_user.reload
          expect(order_user.delivered).to be true
          expect(order_admin.delivered).to be true          
          expect(page).to have_selector 'tr.success', count: 2
          expect(page).not_to have_selector 'tr.danger'
          expect(page).to have_link 'Ні', count: 2
          expect(page).not_to have_link 'Так'
        end # when product visible (default)

        scenario 'when product invisible' do
          expect(page).to have_selector 'tr.danger', count: 2
          expect(page).to have_link 'Так', count: 2
          expect(page).not_to have_link 'Ні'
          expect(order_admin.delivered).to be false
          expect(order_admin.delivered).to be false
          
          first(:link, 'Так').click
          order_admin.reload
          expect(order_admin.delivered).to be true
          expect(order_user.delivered).to be false
          expect(page).to have_selector 'tr.success'
          expect(page).to have_selector 'tr.danger'
          expect(page).to have_link 'Ні'
          expect(page).to have_link 'Так'

          click_on 'Так'
          order_user.reload
          expect(order_user.delivered).to be true
          expect(order_admin.delivered).to be true
          expect(page).to have_selector 'tr.success', count: 2
          expect(page).not_to have_selector 'tr.danger'
          expect(page).to have_link 'Ні', count: 2
          expect(page).not_to have_link 'Так'
        end # when product invisible
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # orders page

  context 'accounts page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_admin.update_attribute(:name, 'admin') }
        before { account_user.update_attributes(visible: e[0], locked: e[1], name: 'user') }
        before { sign_in user_admin }
        before { click_on 'Користувачі' }
        
        scenario 'admin account hide' do
          expect(current_path).to eq accounts_path
          expect(page).not_to have_content account_admin.name
          expect(page).not_to have_link account_admin.name
        end # admin account hide

        scenario 'user account available' do
          expect(current_path).to eq accounts_path
          expect(page).to have_link account_user.name
          expect(page).to have_link 'Перевірено'
          expect(page).to have_link 'Приховувати' if account_user.visible?
          expect(page).to have_link 'Показувати' unless account_user.visible?
          expect(page).to have_link 'Розблокувати' if account_user.locked?
          expect(page).to have_link 'Заблокувати' unless account_user.locked?
          expect(page).to have_link 'Видалити' 
        end # user account available
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # accounts page

  context 'products page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      scenario "when user account visible = #{e[0]}, locked = #{e[1]}" do
        account_admin.update_attribute(:name, 'admin')
        account_user.update_attributes(visible: e[0], locked: e[1], name: 'user')
        product_user.update_attribute(:visible, false)
        sign_in user_admin
        click_on 'Товари'

        expect(current_path).to eq products_path
        expect(page).to have_link account_user.name
        expect(page).to have_link account_admin.name
        expect(page).to have_link 'Перевірено'
        expect(page).to have_link 'Приховувати'
        expect(page).to have_link 'Показувати'
        expect(page).to have_link 'Видалити'
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # products page

  context 'news page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      scenario "when user account visible = #{e[0]}, locked = #{e[1]}" do
        account_admin.update_attribute(:name, 'admin')
        account_user.update_attributes(visible: e[0], locked: e[1], name: 'user')
        article_admin.update_attribute(:visible, false)
        sign_in user_admin
        click_on 'Новини'

        expect(current_path).to eq articles_path
        expect(page).to have_link account_user.name
        expect(page).to have_link account_admin.name
        expect(page).to have_link 'Приховувати'
        expect(page).to have_link 'Показувати'
        expect(page).to have_link 'Редагувати'
        expect(page).to have_link 'Видалити'
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # news page

  context 'account page' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account_user.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user_admin }

        scenario 'account actions' do
          visit account_path(account_user)
          expect(current_path).to eq account_path(account_user)
          expect(page).to have_selector '#edit_account'
          expect(page).to have_link 'Видалити'

          find('#edit_account').click
          expect(current_path).to eq edit_account_path(account_user)
          expect(page).to have_button 'Зберегти'
        end # account actions

        scenario 'when product visible (default)' do
          visit account_path(account_user)
          expect(page).to have_link 'Додати товар'
          within '#product_0' do
            expect(page).to have_link 'Редагувати'
            expect(page).to have_link 'Видалити'
            expect(page).to have_link 'Перевірено'
            expect(page).not_to have_link 'Обрати' unless account_user.visible?
            click_on 'Обрати' if account_user.visible?
          end
          if account_user.visible?
            expect(current_path).to eq new_product_order_path(product_user)
            expect(page).to have_button 'Оформити'
          end

          visit account_path(account_user)
          click_on 'Підтримати цю дитину'
          expect(current_path).to eq account_products_path(account_user)
          expect(page).to have_link 'Додати товар'
          within '#product_0' do
            expect(page).to have_link 'Редагувати'
            expect(page).to have_link 'Видалити'
            expect(page).to have_link 'Перевірено'
            expect(page).not_to have_link 'Обрати' unless account_user.visible?
            click_on 'Обрати' if account_user.visible?
          end
          if account_user.visible?
            expect(current_path).to eq new_product_order_path(product_user)
            expect(page).to have_button 'Оформити'
          end
        end # when product visible (default)

        scenario 'when product invisible' do
          product_user.update_attribute(:visible, false)
          visit account_path(account_user)
          expect(page).to have_link 'Додати товар'
          within '#product_0' do
            expect(page).to have_link 'Редагувати'
            expect(page).to have_link 'Видалити'
            expect(page).to have_link 'Перевірено'
            expect(page).not_to have_link 'Обрати'
          end

          visit account_path(account_user)
          click_on 'Підтримати цю дитину'
          expect(current_path).to eq account_products_path(account_user)
          expect(page).to have_link 'Додати товар'
          within '#product_0' do
            expect(page).to have_link 'Редагувати'
            expect(page).to have_link 'Видалити'
            expect(page).to have_link 'Перевірено'
            expect(page).not_to have_link 'Обрати'
          end
        end # when product invisible

        scenario 'when article visible (default)' do
          visit account_path(account_user)
          within '.section-tabs' do
            click_on 'Новини'
            expect(page).to have_link 'Додати'
            within '.article' do
              expect(page).to have_link article_user.title
              expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
              expect(page).to have_link 'Детальніше ...' 
              expect(page).to have_link 'Редагувати'
              expect(page).to have_link 'Видалити'
              click_on article_user.title
            end
          end # .section-tabs
          expect(current_path).to eq article_path(article_user)
          expect(page).to have_content article_user.title
          expect(page).to have_link 'Редагувати'
          expect(page).to have_link 'Видалити'
        end # when article visible (default)

        scenario 'when article invisible' do
          article_user.update_attribute(:visible, false)
          visit account_path(account_user)
          within '.section-tabs' do
            click_on 'Новини'
            expect(page).to have_link 'Додати'
            within '.article' do
              expect(page).to have_link article_user.title
              expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
              expect(page).to have_link 'Детальніше ...' 
              expect(page).to have_link 'Редагувати'
              expect(page).to have_link 'Видалити'
              click_on article_user.title
            end
          end # .section-tabs
          expect(current_path).to eq article_path(article_user)
          expect(page).to have_content article_user.title
          expect(page).to have_link 'Редагувати'
          expect(page).to have_link 'Видалити'
        end # when article invisible
      end # when user account visible? locked?
    end # generate user account parameters (visible, locked)
  end # account page
end # Admin routes and links
