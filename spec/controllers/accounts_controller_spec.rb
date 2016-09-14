require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  # accounts GET         #accounts#index
  # edit_account GET     #accounts#edit
  # account GET          #account#show
  #   PATCH              #accounts#update
  #   PUT                #accounts#update
  #   DELETE             #accounts#destroy
  # checked_account GET  #accounts#checked
  # visible_account GET  #accounts#visible
  # locked_account GET   #accounts#locked

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
  let(:account_user) { user.account }
  let(:account_admin) { user_admin.account }
  let(:images) { create_list(:image, 2, imageable: account_user) }
  let(:products) { create_list(:product, 2, account: account_user) }
  let(:products_admin) { create_list(:product, 2, account: account_admin) }
  let(:orders) { create_list(:order, 2, account: account_user) }
  let(:articles) { create_list(:article, 2, account: account_user) }
  let(:articles_admin) { create_list(:article, 2, account: account_admin) }
  let(:invisible_product_user) { create(:product, account: account_user, visible: false) }
  let(:invisible_article_user) { create(:article, account: account_user, visible: false) }
  let(:invisible_product_admin) { create(:product, account: account_admin, visible: false) }
  let(:invisible_article_admin) { create(:article, account: account_admin, visible: false) }

  describe 'GET #index' do
    it 'visitor redirect to sign_in page' do
      get :index
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    it 'user redirect to home page' do
      sign_in user
      get :index
      expect(response).to redirect_to root_path
    end # role: user

    context 'admin, visible and invisible user accounts' do
      before { account_user.update_attribute(:visible, true) }
      before { account_admin }
      before { sign_in user_admin }
      before { get :index }
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of all accounts' do
        expect(assigns(:accounts)).not_to be_empty
        expect(assigns(:accounts)).to match_array Account.all
      end
    end # role: admin. visible and invisible user accounts

    context 'admin, visible, locked and invisible accounts' do
      before { account_user.update_attributes(
          visible: true,
          locked: true
        ) }
      before { account_admin }
      before { sign_in user_admin }
      before { get :index }
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of all accounts' do
        expect(assigns(:accounts)).not_to be_empty
        expect(assigns(:accounts)).to match_array Account.all
      end
    end # role: admin. visible, locked and invisible user accounts
  end # GET #index

  describe 'GET #show' do
    context 'visitor invisible account' do
      before { get :show, id: account_user }
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_user
      end
      it 'populates nil account products and articles' do
        expect(assigns(:products)).to be_nil
        expect(assigns(:articles)).to be_nil
      end
    end # role: visitor. default

    context 'visitor' do
      before { account_user.update_attribute(:visible, true) }
      before { invisible_product_user }
      before { invisible_article_user }
      before { products }
      before { articles }
      before { get :show, id: account_user }
      it 'renders show account view' do
        expect(response).to render_template :show
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_user
      end
      it 'populates only visible account products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array products
      end
      it 'populates only visible account articles' do
        expect(assigns(:articles)).not_to be_empty
            expect(assigns(:articles)).to match_array articles
      end
    end # role: visitor. visible user account

    context 'visitor' do
      before { account_user.update_attributes(
        visible: true,
        locked: true
      ) }
      before { invisible_product_user }
      before { invisible_article_user }
      before { products }
      before { articles }
      before { get :show, id: account_user }
      it 'renders show account view' do
        expect(response).to render_template :show
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_user
      end
      it 'populates only visible account products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array products
      end
      it 'populates only visible account articles' do
        expect(assigns(:articles)).not_to be_empty
            expect(assigns(:articles)).to match_array articles
      end
    end # role: visitor. visible, locked user account

    # invisible, unlocked user account (default)
    %w(user admin).each do |role|
      context role do
        before { invisible_product_user }
        before { invisible_article_user }
        before { products }
        before { articles }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :show, id: account_user }
        it 'renders show account view' do
          expect(response).to render_template :show
        end
        it 'populates an account' do
          expect(assigns(:account)).to eq account_user
        end
        it 'populates all account products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products
        end
        it 'populates all account articles' do
          expect(assigns(:articles)).not_to be_empty
          expect(assigns(:articles)).to match_array account_user.articles
        end
      end # default
    end # roles: user, admin

    # invisible, unlocked user account (default)
    # someone else\'s account page
    context 'user' do
      before { account_admin.update_attribute(:visible, true) }
      before { invisible_product_admin }
      before { invisible_article_admin }
      before { products_admin }
      before { articles_admin }
      before { sign_in user }
      before { get :show, id: account_admin }
      it 'renders show account view' do
        expect(response).to render_template :show
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_admin
      end
      it 'populates all account products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array account_admin.products
      end
      it 'populates all account articles' do
        expect(assigns(:articles)).not_to be_empty
        expect(assigns(:articles)).to match_array account_admin.articles
      end
    end # role: user. someone else\'s account page

    # invisible, locked user account
     %w(user admin).each do |role|
      context role do
        before { account_user.update_attribute(:locked, true) }
        before { invisible_product_user }
        before { invisible_article_user }
        before { products }
        before { articles }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :show, id: account_user }
        it 'renders show account view' do
          expect(response).to render_template :show
        end
        it 'populates an account' do
          expect(assigns(:account)).to eq account_user
        end
        it 'populates all account products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products
        end
        it 'populates all account articles' do
          expect(assigns(:articles)).not_to be_empty
          expect(assigns(:articles)).to match_array account_user.articles
        end
      end # locked user account
    end # roles: user, admin
  end # GET #show

  describe 'GET #edit' do
    it 'visitor redirect to sign in page' do
      get :edit, id: account_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. default

    it 'when user wants to edit someone else\'s account' do
      sign_in user
      get :edit, id: account_admin
      expect(response).to redirect_to root_path
    end # role: user. someone else\'s account

    it 'user locked account redirect to home page' do
      account_user.update_attribute(:locked, true)
      sign_in user
      get :edit, id: account_user
      expect(response).to redirect_to root_path
    end # role: user. locked user account

    context 'user' do
      before { sign_in user }
      before { get :edit, id: account_user }
      it 'renders edit view' do
        expect(response).to render_template :edit
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_user
      end
    end # role: user. default

    context 'admin edit locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      before { get :edit, id: account_user }
      it 'renders edit view' do
        expect(response).to render_template :edit
      end
      it 'populates an account' do
        expect(assigns(:account)).to eq account_user
      end
    end # role: admin. locked user account

    context 'admin' do
      before { sign_in user_admin }
      before { get :edit, id: account_user }
      it 'renders edit view for user account' do
        expect(response).to render_template :edit
      end
      it 'populates an user account' do
        expect(assigns(:account)).to eq account_user
      end
    end # role: admin. default
  end # GET #edit

  describe 'PATCH #update' do
    it 'visitor redirect to sign in' do
      patch :update, id: account_user, account: { name: 'Bob' }
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    context 'when user wants to update someone else\'s account' do
      before { sign_in user }
      before { patch :update, id: account_admin, account: { name: 'Admin' } }
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
      it 'not changes account attributes' do
        account_admin.reload
        expect(account_admin.name).not_to eq 'Admin'
      end
    end # role: user. someone else\'s account

    context 'user' do
      before { sign_in user }
      it 'assings the requested account to @account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(assigns(:account)).to eq account_user
      end
      it 'changes account attributes' do
        patch :update, id: account_user, account: { name: 'Lilu' }
        account_user.reload
        expect(account_user.name).to eq 'Lilu'
      end
      it 'redirects to the updated account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(response).to redirect_to account_user
      end
    end # role: user. default

    context 'when user edit own locked account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user }
      it 'assings the requested account to @account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(assigns(:account)).to eq account_user
      end
      it 'not changes account attributes' do
        patch :update, id: account_user, account: { name: 'Lilu' }
        account_user.reload
        expect(account_user.name).not_to eq 'Lilu'
      end
      it 'redirects to home page' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(response).to redirect_to root_path
      end
    end # role: user. locked user account
  
    context 'admin' do
      before { sign_in user_admin }
      it 'assings the requested account to @account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(assigns(:account)).to eq account_user
      end
      it 'changes account attributes' do
        patch :update, id: account_user, account: { name: 'Lilu' }
        account_user.reload
        expect(account_user.name).to eq 'Lilu'
      end
      it 'redirects to the updated account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(response).to redirect_to account_user
      end
    end # role: admin. default    

    context 'when admin edit locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      it 'assings the requested account to @account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(assigns(:account)).to eq account_user
      end
      it 'changes account attributes' do
        patch :update, id: account_user, account: { name: 'Lilu' }
        account_user.reload
        expect(account_user.name).to eq 'Lilu'
      end
      it 'redirects to the updated account' do
        patch :update, id: account_user, account: { name: 'Bob' }
        expect(response).to redirect_to account_user
      end
    end # role: admin. locked user account
  end # PATCH #update
  
  describe 'DELETE #destroy' do
    %w(visitor user).each do |role|
      it "#{role} redirect to sign in or home page" do
        sign_in user if role == 'user'
        delete :destroy, id: account_user
        expect(response).to redirect_to new_user_session_path if role == 'visitor'
        expect(response).to redirect_to root_path if role == 'user'
      end # role: visitor
    end # roles: visitor, user

    context 'admin' do
      before { account_user }
      before { images }
      before { products }
      before { orders }
      before { articles }
      before { sign_in user_admin }
      it 'deletes user account' do
        expect { delete :destroy, id: account_user }
          .to change(User, :count).by(-1)
          .and change(Account, :count).by(-1)
          .and change(Image, :count).by(-2)
          .and change(Product, :count).by(-2)
          .and change(Order, :count).by(-2)
          .and change(Article, :count).by(-2)
      end
      it 'redirect to accounts page' do
        delete :destroy, id: account_user
        expect(response).to redirect_to accounts_path
      end
    end # admin

    it 'when user delete own locked account, redirects to home page' do
      account_user.update_attribute(:locked, true)
      sign_in user
      delete :destroy, id: account_user
      expect(response).to redirect_to root_path
    end # when user

    context 'admin' do
      before { account_user }
      before { account_user.update_attribute(:locked, true) }
      before { images }
      before { products }
      before { orders }
      before { articles }
      before { sign_in user_admin }
      it 'deletes user account' do
        expect { delete :destroy, id: account_user }
          .to change(User, :count).by(-1)
          .and change(Account, :count).by(-1)
          .and change(Image, :count).by(-2)
          .and change(Product, :count).by(-2)
          .and change(Order, :count).by(-2)
          .and change(Article, :count).by(-2)
      end
      it 'redirect to accounts page' do
        delete :destroy, id: account_user
        expect(response).to redirect_to accounts_path
      end
    end # role: admin
  end # DELETE #destroy

  describe 'GET #checked' do
    %w(visitor user).each do |role|
      it "#{role} redirects to sign in or home page" do
        sign_in user if role == 'user'
        get :checked, id: account_user
        expect(response).to redirect_to new_user_session_path if role == 'visitor'
        expect(response).to redirect_to root_path if role == 'user'
      end
    end # roles: visitor, user

    context 'admin' do
      before { sign_in user_admin }
      it 'checked user account' do
        expect { get :checked, id: account_user }
          .to change { Account.find(account_user.id).prev_updated_at }
      end
      it 'redirects to accounts page' do
        get :checked, id: account_user
        expect(response).to redirect_to accounts_path
      end
    end # role: admin
  end # GET #checked

  describe 'GET #visible' do
    %w(visitor user).each do |role|
      it "#{role} redirects to sign in or home page" do
        sign_in user if role == 'user'
        get :visible, id: account_user
        expect(response).to redirect_to new_user_session_path if role == 'visitor'
        expect(response).to redirect_to root_path if role == 'user'
      end
    end # roles: visitor, user

    context 'admin' do
      before { sign_in user_admin }
      it 'visible user account' do
        expect { get :visible, id: account_user }
          .to change { Account.find(account_user.id).visible }
      end
      it 'redirects to accounts page' do
        get :visible, id: account_user
        expect(response).to redirect_to accounts_path
      end
    end # role: admin
  end # GET #visible

  describe 'GET #locked' do
    %w(visitor user).each do |role|
      it "#{role} redirects to sign in or home page" do
        sign_in user if role == 'user'
        get :locked, id: account_user
        expect(response).to redirect_to new_user_session_path if role == 'visitor'
        expect(response).to redirect_to root_path if role == 'user'
      end
    end # roles: visitor, user

    context 'admin' do
      before { sign_in user_admin }
      it 'locked user account' do
        expect { get :locked, id: account_user }
          .to change { Account.find(account_user.id).locked }
      end
      it 'redirects to accounts page' do
        get :locked, id: account_user
        expect(response).to redirect_to accounts_path
      end
    end # role: admin
  end # GET #locked
end # AccountsController
