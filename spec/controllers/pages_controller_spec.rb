require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  # root GET      pages#home
  # products GET  pages#products

  # roles: visitor, user, admin
  # user account visible, locked
  # product visible
  # article visible
  
  # Default
  #   user account: visible = false, locked = false
  #   product: visible = true
  #   article: visible = true

  let(:user) { create(:user) }
  let(:user_admin) { create(:user_admin) }
  let(:default_user) { create(:user) }
  let(:account_user) { user.account }
  let(:account_admin) { user_admin.account }
  let(:account_invisible_user) { default_user.account }
  let(:articles_user) { create_list(:article, 2, account: account_user) }
  let(:article_admin) { create(:article, account: account_admin) }
  let(:product_user) { create(:product, account: account_user) }
  let(:product_admin) { create(:product, account: account_admin) }

  describe 'GET #home' do
    %w(visitor user admin).each do |role|
      context role do
        before do
          create(:article, account: account_user)
          create_list(:article, 5, account: account_admin)
          create_list(:article, 3, account: account_admin, visible: false)

          create_list(:user, 10).each_with_index do |e, i|
            e.account.update_attribute(:visible, true)
            if i == 7 || i == 8 || i == 9
              create_list(:article, 2, account: e.account)
              create(:article, account: e.account, visible: false)
            end
          end

          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :home
        end
        it 'renders home view' do
          expect(response).to render_template :home
        end
        it 'populates an array of 9 visible accounts' do
          expect(assigns(:accounts)).not_to be_empty
          expect(assigns(:accounts)).to match_array Account.where(visible: true).order(deadline_on: :asc).limit(9)
          expect(assigns(:accounts)).not_to include account_user
          expect(assigns(:accounts)).not_to include account_admin
        end
        it 'populates an array of 9 visible articles and visible accounts and admin visible articles' do
          visible_accounts_and_articles = Article.where(account: Account.last(3), visible: true)  # 6
          all_admin_visible_articles    = account_admin.articles.where(visible: true)             # 5
          expect(assigns(:articles)).not_to be_empty
          expect(assigns(:articles)).not_to match_array visible_accounts_and_articles + all_admin_visible_articles
          expect(assigns(:articles)).to match_array visible_accounts_and_articles + all_admin_visible_articles.last(3)
        end
      end
    end # roles: visitor, user, admin
  end # GET #home

  describe 'GET #products' do
    
    %w(visitor user).each do |role|
      context role do
        before { sign_in user } if role == 'user'
        before { get :products }
        it 'populates an nil array' do
          expect(assigns(:products)).to be_nil
        end
        it 'redirect to home page' do
          expect(response).to redirect_to new_user_session_path if role == 'visitor'
          expect(response).to redirect_to root_path if role == 'user'
        end
      end
    end # roles: visitor, user

    context 'admin' do
      before { product_admin.update_attribute(:visible, false) }
      before { product_user }
      before { create_list(:product, 9, account: account_user) }
      before { sign_in user_admin }
      before { get :products }
      it 'renders products view' do
        expect(response).to render_template :products
      end
      it 'populates an array of all products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array Product.all.order(account_id: :asc, created_at: :desc).limit(10)
      end
    end # role: admin
  end # GET #products
end # PagesController
