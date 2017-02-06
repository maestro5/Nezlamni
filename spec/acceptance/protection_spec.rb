require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor close routes and links', %q{
  As a visitor
  I want to not be available to User and Admin links
} do

  let(:user)     { create :user }
  let(:account)  { create :account, user: user }
  let(:product) { create :product, account: account }
  let!(:article) { create :article, account: account }
  let(:order)    { create :order,   product: product }

  scenario 'menu items' do
    visit root_path
    expect(page).to have_link 'Зібрати кошти'
    expect(page).to have_link 'Реєстрація'
    expect(page).to have_link 'Увійти'
    expect(page).not_to have_link 'Збори'
    expect(page).not_to have_link 'Замовлення'
    expect(page).not_to have_link 'Товари'
    expect(page).not_to have_link 'Користувачі'
    expect(page).not_to have_link 'Новини'
    expect(page).not_to have_link 'Вийти'
  end # menu items

  context 'home page, accounts and articles' do
    scenario 'when default user account' do
      article.update_attribute(:visible, false)

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
    end 

    scenario 'when invisible user account' do
      # invisible user article
      account.update_attribute(:visible, true)
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
      within '.product-default' do
        expect(page).not_to have_link 'Редагувати'
        expect(page).not_to have_link 'Видалити'
        expect(page).not_to have_link 'Перевірено'
        expect(page).to have_link 'Обрати'
      end

      # support child
      click_on 'Підтримати цю людину'
      expect(page).not_to have_link 'Додати товар'
      within '.product-default' do
        expect(page).not_to have_link 'Редагувати'
        expect(page).not_to have_link 'Видалити'
        expect(page).not_to have_link 'Перевірено'
        expect(page).to have_link 'Обрати'
      end
    end # when product default

    scenario 'when product invisible' do
      product.update_attribute(:visible, false)
      visit account_path(account)
      expect(page).not_to have_link 'Додати товар'
      expect(page).not_to have_content product.title

      # account support child
      click_on 'Підтримати цю людину'
      expect(page).not_to have_link 'Додати товар'
      expect(page).not_to have_content product.title
    end # when product invisible
  
    scenario 'when article default' do
      visit account_path(account)
      within '.section-tabs' do
        click_on 'Новини'
        expect(page).not_to have_link 'Додати'

        within '.article' do
          expect(page).to have_link article.title
          expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
          expect(page).to have_link 'детальніше' if article.description.length >= 300
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

# =====================================
# role: user
# =====================================
feature 'User close routes and links', %q{
  As a user
  I want to not be available to close User and Admin links
} do

  let(:user)              { create :user }
  let(:user_two)          { create :user }
  let(:account)           { create :account, user: user }
  let(:account_two)       { create :account, user: user_two }
  let(:product_user)      { account.products.first }
  let!(:product_user_two) { account_two.products.first }
  let!(:article_user)     { create :article, account: account }
  let(:article_user_two)  { create :article, account: account_two }
  let!(:order_user)       { create :order, product: product_user, account: account }

  scenario 'menu items' do
    sign_in user
    expect(page).to have_link 'Зібрати кошти'
    expect(page).to have_link 'Збори'
    expect(page).to have_link 'Замовлення'
    expect(page).not_to have_link 'Товари'
    expect(page).not_to have_link 'Користувачі'
    expect(page).not_to have_link 'Новини'
    expect(page).to have_link 'Вийти'
  end # menu items

  context 'home page, avatars and articles' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        scenario 'when article visible (default)' do
          visit root_path
          if account.visible?
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
          if account.visible?
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
        before { account.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }
        before { click_on 'Замовлення' }

        scenario 'when product visible (default)' do
          expect(page).to have_selector 'tr.danger'
          expect(page).to have_link 'Так'
          expect(page).not_to have_link 'Ні'
          
          unless account.locked?
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
          unless account.locked?
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
        before { account.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        scenario 'available links' do
          visit account_path(account)
          expect(current_path).to eq account_path(account)
          if account.locked?
            expect(page).not_to have_selector '#edit_account'
            expect(page).not_to have_link 'Видалити'
          else
            expect(page).to have_selector '#edit_account'
            expect(page).to have_link 'Видалити'

            find('#edit_account').click
            expect(current_path).to eq edit_account_path(account)
            expect(page).to have_button 'Зберегти'
          end # account.locked?
        end # available links

        scenario 'when user on someone else\'s account page' do
          account_two.update_attribute(:visible, true)
          visit account_path(account_two)
          expect(current_path).to eq account_path(account_two)
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
        before { account.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        context 'when product visible (default)' do
          scenario 'actions' do
            visit account_path(account)
            if account.locked?
              expect(page).not_to have_link 'Додати товар'
              within '.product-default' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account.visible?
                click_on 'Обрати' if account.visible?
              end
              if account.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end

              visit account_path(account)
              click_on 'Підтримати цю людину'
              expect(current_path).to eq account_products_path(account)
              expect(page).not_to have_link 'Додати товар'
              within '.product-default' do
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account.visible?
                click_on 'Обрати' if account.visible?
              end
              if account.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end
            else
              expect(page).to have_link 'Додати товар'
              within '.product-default' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account.visible?
                click_on 'Обрати' if account.visible?
              end
              if account.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end

              visit account_path(account)
              click_on 'Підтримати цю людину'
              expect(page).to have_link 'Додати товар'
              within '.product-default' do
                expect(page).to have_link 'Редагувати'
                expect(page).to have_link 'Видалити'
                expect(page).not_to have_link 'Перевірено'
                expect(page).not_to have_link 'Обрати' unless account.visible?
                click_on 'Обрати' if account.visible?                  
              end
              if account.visible?
                expect(current_path).to eq new_product_order_path(product_user)
                expect(page).to have_button 'Оформити'
              end
            end # account.locked?
          end # product actions

          scenario 'when user on someone else\'s account page' do
            account_two.update_attribute(:visible, true)
            visit account_path(account_two)

            expect(current_path).to eq account_path(account_two)
            expect(page).not_to have_link 'Додати товар'
            within '.product-default' do
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
              expect(page).not_to have_link 'Перевірено'
              click_on 'Обрати'
            end
            expect(current_path).to eq new_product_order_path(product_user_two)
            expect(page).to have_button 'Оформити'

            visit account_path(account_two)
            click_on 'Підтримати цю людину'
            expect(current_path).to eq account_products_path(account_two)
            expect(page).not_to have_link 'Додати товар'
            within '.product-default' do
              expect(page).not_to have_link 'Редагувати'
              expect(page).not_to have_link 'Видалити'
              expect(page).not_to have_link 'Перевірено'
              click_on 'Обрати'
            end
            expect(current_path).to eq new_product_order_path(product_user_two)
            expect(page).to have_button 'Оформити'
          end # when user on someone else\'s account page
        end # when product visible (default)

        context 'when product invisible' do
          scenario 'actions' do
            product_user.update_attribute(:visible, false)
            visit account_path(account)
            
            if account.locked?
              expect(page).not_to have_link 'Додати товар'
              expect(page).not_to have_css '.product-default'
              click_on 'Підтримати цю людину'
              expect(page).not_to have_link 'Додати товар'
              expect(page).not_to have_css '.product-default'
            else
              expect(page).to have_link 'Додати товар'
              expect(page).not_to have_css '.product-default'
              click_on 'Підтримати цю людину'
              expect(page).to have_link 'Додати товар'
              expect(page).not_to have_css '.product-default'
            end # account.locked?
          end # product actions

          scenario 'when user visit someone else\'s account page' do
            account_two.update_attribute(:visible, true)
            product_user_two.update_attribute(:visible, false)
            visit account_path(account_two)

            expect(current_path).to eq account_path(account_two)
            expect(page).not_to have_link 'Додати товар'
            expect(page).not_to have_selector product_user_two.title

            click_on 'Підтримати цю людину'
            expect(page).not_to have_link 'Додати товар'
            expect(page).not_to have_selector product_user_two.title
          end # when user on someone else\'s account page
        end # when product invisible
      end # when user account visible? locked?  
    end # generate user account parameters (visible, locked)
  end # account page, product actions

  context 'account page, article actions' do
    # generate user account parameters (visible, locked)
    [false, true].repeated_permutation(2).each do |e|
      context "when user account visible = #{e[0]}, locked = #{e[1]}" do
        before { account.update_attributes(visible: e[0], locked: e[1]) }
        before { sign_in user }

        context 'when article visible (default)' do
          scenario 'actions' do
            visit account_path(account)
            expect(current_path).to eq account_path(account)

            if account.locked?
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).not_to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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
                  expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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

          scenario 'when user on someone else\'s account page' do
            account_two.update_attribute(:visible, true)
            article_user_two
            visit account_path(account_two)
            expect(current_path).to eq account_path(account_two)
            within '.section-tabs' do
              click_on 'Новини'
              expect(page).not_to have_link 'Додати'
              within '.article' do
                expect(page).to have_link article_user_two.title
                expect(page).to have_css('a[href=\'' + article_path(article_user_two) + '\']')
                expect(page).to have_link 'детальніше' if article_user_two.description.length >= 300 
                expect(page).not_to have_link 'Редагувати'
                expect(page).not_to have_link 'Видалити'
                click_on article_user_two.title
              end
            end # .section-tabs
            expect(current_path).to eq article_path(article_user_two)
            expect(page).to have_content article_user_two.title
            expect(page).not_to have_link 'Редагувати'
            expect(page).not_to have_link 'Видалити'
          end # when user on someone else\'s account page
        end # when article visible (default)

        context 'when article invisible' do
          scenario 'actions' do
            article_user.update_attribute(:visible, false)
            visit account_path(account)
            expect(current_path).to eq account_path(account)

            if account.locked?
              within '.section-tabs' do
                click_on 'Новини'
                expect(page).not_to have_link 'Додати'
                within '.article' do
                  expect(page).to have_link article_user.title
                  expect(page).to have_css('a[href=\'' + article_path(article_user) + '\']')
                  expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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
                  expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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
            account_two.update_attribute(:visible, true)
            article_user_two.update_attribute(:visible, false)
            
            visit account_path(account_two)
            expect(current_path).to eq account_path(account_two)
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

# =====================================
# role: admin
# =====================================
feature 'Admin routes and links', %q{
  As an admin
  I want to be available to all routes and links
} do

  let(:user_admin) { create :user_admin }
  let(:user)       { create :user }
  let(:user_two)   { create :user }
  
  # let(:account_admin) { user_admin.account }
  let(:account_user)      { create(:account, user: user) }
  let(:account_user_two)  { create(:account, user: user_two) }

  let!(:product_user)     { create :product, account: account_user }
  let!(:product_user_two) { create :product, account: account_user_two }
  # let!(:product_admin) { create :product, account: account_admin }
  let!(:article_user) { create :article, account: account_user }
  let(:article_admin) { create :article, link: 'youtube.com' }
  let!(:order_user)   { create :order, product: product_user, account: account_user }
  let!(:order_admin)  { create :order, product: product_user_two, account: account_user_two }

  scenario 'menu items' do
    sign_in user_admin
    expect(page).to have_link 'Зібрати кошти'
    expect(page).to have_link 'Збори'
    expect(page).to have_link 'Замовлення'
    expect(page).to have_link 'Товари'
    expect(page).to have_link 'Користувачі'
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
        before { account_user.update_attributes(visible: e[0], locked: e[1], name: 'user') }
        before { sign_in user_admin }
        before { click_on 'Збори' }

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
        account_user.update_attributes(visible: e[0], locked: e[1], name: 'user')
        product_user.update_attribute(:visible, false)
        sign_in user_admin
        click_on 'Товари'

        expect(current_path).to eq products_path
        expect(page).to have_link account_user.name
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
        # account_admin.update_attribute(:name, 'admin')
        account_user.update_attributes(visible: e[0], locked: e[1], name: 'user')
        article_admin.update_attribute(:visible, false)
        sign_in user_admin
        click_on 'Новини'

        expect(current_path).to eq articles_path
        expect(page).to have_link account_user.name
        expect(page).to have_link article_admin.link
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
          within all('.product').last do
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
          click_on 'Підтримати цю людину'
          expect(current_path).to eq account_products_path(account_user)
          expect(page).to have_link 'Додати товар'
          within all('.product').last do
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
          within all('.product').last do
            expect(page).to have_link 'Редагувати'
            expect(page).to have_link 'Видалити'
            expect(page).to have_link 'Перевірено'
            expect(page).not_to have_link 'Обрати'
          end

          visit account_path(account_user)
          click_on 'Підтримати цю людину'
          expect(current_path).to eq account_products_path(account_user)
          expect(page).to have_link 'Додати товар'
          within all('.product').last do
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
              expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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
              expect(page).to have_link 'детальніше' if article_user.description.length >= 300 
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
