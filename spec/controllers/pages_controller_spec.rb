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
  let(:account_user) { create(:account, user: user) }
  let(:account_admin) { create(:account, user: user_admin) }
  let(:account_invisible_user) { default_user.account }
  let(:articles_user) { create_list(:article, 2, account: account_user) }
  let(:article_admin) { create(:article) }
  let(:product_user) { create(:product, account: account_user) }
  let(:product_admin) { create(:product, account: account_admin) }

  describe 'GET #home' do
    %w(visitor user admin).each do |role|
      context role do
        before do
          article_admin
          create(:article, account: account_user)
          create_list(:article, 5)
          create_list(:article, 3, visible: false)

          create_list(:account, 10, user: user, visible: true).each_with_index do |e, i|
            if (7..9).include? i
              create_list(:article, 2, account: e)
              create(:article, account: e, visible: false)
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
          # visible user and admin articles in visible accounts
          articles = 
            Article
              .joins("LEFT OUTER JOIN accounts ON accounts.id = articles.account_id")
              .where('(accounts.visible=? OR articles.account_id IS ?) AND articles.visible=?', true, nil, true)
              .order(created_at: :desc)
              .limit(9)
          expect(assigns(:articles)).not_to be_empty
          expect(assigns(:articles)).to match_array articles
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
      before do
        product_admin.update_attribute(:visible, false)
        product_user
        create_list(:product, 9, account: account_user)
        sign_in user_admin
        get :products
      end
      it 'renders products view' do
        expect(response).to render_template :products
      end
      it 'populates an array of all products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products))
          .to match_array Product.where(default: false).order(account_id: :asc, created_at: :desc).limit(10)
      end
    end # role: admin
  end # GET #products
end # PagesController
