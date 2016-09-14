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
          account_user.update_attribute(:visible, true)
          account_admin.update_attribute(:visible, true)
          account_invisible_user
          articles_user
          article_admin.update_attribute(:visible, false)
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :home
        end
        it 'renders home view' do
          expect(response).to render_template :home
        end
        it 'populates an array of all visible accounts' do
          expect(assigns(:accounts)).not_to be_empty
          expect(assigns(:accounts)).to match_array [account_user, account_admin]
        end
        it 'populates an array of all visible articles' do
          expect(assigns(:articles)).not_to be_empty
          expect(assigns(:articles)).to match_array articles_user
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
      before { sign_in user_admin }
      before { get :products }
      it 'renders products view' do
        expect(response).to render_template :products
      end
      it 'populates an array of all products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array [product_admin, product_user]
      end
    end # role: admin
  end # GET #products
end # PagesController
