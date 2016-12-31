require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  # account_products GET         products#index
    # POST                       products#create
  # new_account_product GET      products#new
  # edit_product GET             products#edit
  # product GET                  products#show
  #   PATCH                      products#update 
  #   PUT                        products#update 
  #   DELETE                     products#destroy 
  # checked_product GET          products#checked
  # visible_product GET          products#visible

  # roles: visitor, user, admin
  # user account visible, locked
  # product visible
  
  # Default
  #   user account: visible = false, locked = false
  #   product: visible = true

  let(:user) { create(:user) }
  let(:user_admin) { create(:user_admin) }
  let(:account_user) { create(:account, user: user) }
  let(:account_admin) { create(:account, user: user_admin) }
  let(:product_user) { create(:product, account: account_user) }
  let(:products_user) { create_list(:product, 2, account: account_user) }
  let(:product_admin) { create(:product, account: account_admin) }
  let(:products_admin) { create_list(:product, 2, account: account_admin) }
  let(:images_product_user) { create_list(:image, 2, imageable: product_user) }
  let(:orders_product_user) { create_list(:order, 2, product: product_user) }

  describe 'GET #index' do
    it 'visitor' do
      product_user
      product_admin
      get :index, account_id: account_user
      expect(response).to redirect_to root_path
    end # role: visitor. default

    %w(user admin).each do |role|
      context role do
        before do
          product_user
          product_admin
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :index, account_id: account_user
        end
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products
        end
      end # default
    end # roles: user, admin

    context 'when user visit someone else\'s account page' do
      before { account_admin.update_attribute(:visible, true) }
      before { product_user }
      before { product_admin.update_attribute(:visible, false) }
      before { products_admin }
      before { sign_in user }
      before { get :index, account_id: account_admin }
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of only visible products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array account_admin.products
      end
    end # role: user. default, someone else\'s account page

    context 'visitor visible user account, invisible product' do
      before do
        account_user.update_attribute(:visible, true)
        product_user.update_attribute(:visible, false)
        product_admin
        get :index, account_id: account_user
      end
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of all products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).not_to match_array account_user.products
      end
    end # role: visitor. visible user account; invisible product

    %w(user admin).each do |role|
      context role do
        before { product_user.update_attribute(:visible, false) }
        before { product_admin }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index, account_id: account_user }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products
        end
      end # invisible product
    end # roles: user, admin

    context 'visitor available products for locked account' do
      before do
        account_user.update_attributes(visible: true, locked: true)
        product_user
        product_admin
        get :index, account_id: account_user
      end
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of only visible products' do
        expect(assigns(:products)).not_to be_empty
        expect(assigns(:products)).to match_array account_user.products
      end      
    end # role: visitor. visible, locked account

    %w(user admin).each do |role|
      context role do
        before do
          account_user.update_attributes(visible: true, locked: true)
          product_user
          product_admin
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :index, account_id: account_user
        end
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products
        end
      end # visible, locked account
    end # roles: user, admin

    %w(visitor user admin).each do |role|
      context role do
        before do
          account_user.update_attribute(:visible, true)
          product_user.update_attribute(:visible, false)
          products_user
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :index, account_id: account_user
        end
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all or only visible products' do
          expect(assigns(:products)).not_to be_empty
          expect(assigns(:products)).to match_array account_user.products.where(visible: true) if role == 'visitor'
          expect(assigns(:products)).to match_array account_user.products unless role == 'visitor'
        end
      end # visible user account
    end # roles: visitor, user, admin
  end # GET #index
  
  describe 'GET #new' do
    it 'visitor invisible user account, redirect to sign in' do
      get :new, account_id: account_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. default

    it 'visitor visible user account, redirect to sign in' do
      account_user.update_attribute(:visible, true)
      get :new, account_id: account_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. visible user account

    it 'when user creates new someone else\'s product' do
      account_admin.update_attribute(:visible, true)
      sign_in user
      get :new, account_id: account_admin
      expect(response).to redirect_to root_path
    end # role: user. visible user account

    %w(user admin).each do |role|
      context "#{role} creates new product for locked account" do
        before { account_user.update_attribute(:locked, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, account_id: account_user }
        it 'assigns a new Product to @product' do
          expect(assigns(:product)).to be_a_new(Product)
        end
        it 'renders new view' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :new if role == 'admin'
        end
      end
    end # roles: user, admin. locked user account

    %w(user admin).each do |role|
      context role do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, account_id: account_user }
        it 'assigns a new Product to @product' do
          expect(assigns(:product)).to be_a_new(Product)
        end
        it 'renders new view' do
          expect(response).to render_template :new
        end
      end # default
    end # roles: user, admin
  end # GET #new
  
  describe 'POST #create' do
    it 'visitor invisible account user, redirect to sign in' do
      post :create, account_id: account_user, product: attributes_for(:product)
      expect(response).to redirect_to new_user_session_path
    end # visitor. default

    it 'visitor visible account user, redirect to sign in' do
      account_user.update_attribute(:visible, true)
      post :create, account_id: account_user, product: attributes_for(:product)
      expect(response).to redirect_to new_user_session_path
    end # visitor. visible user account

    it 'when user creates new else\'s product' do
      account_admin.update_attribute(:visible, true)
      sign_in user
      post :create, account_id: account_admin, product: attributes_for(:product)
      expect(response).to redirect_to root_path
    end # role: user. visible user account

    %w(user admin).each do |role|        
      it "#{role} creates new product for locked account" do
        account_user.update_attribute(:locked, true)
        sign_in user if role == 'user'
        sign_in user_admin if role == 'admin'
        post :create, account_id: account_user, product: attributes_for(:product)
        expect(response).to redirect_to root_path if role == 'user'
        expect(response).to redirect_to account_user if role == 'admin'
      end # locked user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before do
          account_user
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
        end
        it 'saves the new product in the database' do
          expect { post :create, account_id: account_user, product: attributes_for(:product) }
            .to change(Product, :count).by(1)
        end
        it 'renders show view' do
          post :create, account_id: account_user, product: attributes_for(:product)
          expect(response).to redirect_to account_user
        end
      end # default
    end # roles: user, admin
  end # POST #create

  describe 'GET #edit' do
    it 'visitor invisible user account, redirect to sign in' do
      get :edit, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. default

    it 'visitor redirect to sign in' do
      account_user.update_attribute(:visible, true)
      get :edit, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. visible user account

    it 'when user wants to edit someone else\'s product' do
      account_admin.update_attribute(:visible, true)
      sign_in user
      get :edit, id: product_admin
      expect(response).to redirect_to root_path
    end # role: user. visible user account

    %w(user admin).each do |role|
      context "#{role} edits product for locked account" do
        before { account_user.update_attribute(:locked, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :edit, id: product_user }
        it 'populates a product' do
          expect(assigns(:product)).to eq product_user
        end
        it 'renders edit view' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :edit if role == 'admin'
        end
      end # locked user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before { product_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :edit, id: product_user }
        it 'populates a product' do
          expect(assigns(:product)).to eq product_user
        end
        it 'renders edit view' do
          expect(response).to render_template :edit
        end
      end # ivisible product
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :edit, id: product_user }
        it 'populates a product' do
          expect(assigns(:product)).to eq product_user
        end
        it 'renders edit view' do
          expect(response).to render_template :edit
        end
      end # default
    end # roles: user, admin
  end # GET #edit

  describe 'PATCH #update' do
    it 'visitor invisible user account, redirect to sign in' do
      patch :update, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. invisible user account

    it 'visitor visible user account, redirect to sign in' do
      account_user.update_attribute(:visible, true)
      patch :update, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. visible user account

    it 'when user wants to update someone else\'s product' do
      account_admin.update_attribute(:visible, true)
      sign_in user
      patch :update, id: product_admin, product: attributes_for(:product)
      expect(response).to redirect_to root_path
    end # role: user. visible user account

    %w(user admin).each do |role|
      context "#{role} update edited product for locked account" do
        before { account_user.update_attribute(:locked, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { patch :update, id: product_user, product: { title: 'New title'} }
        it 'redirect to home page' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to account_user if role == 'admin'
        end
        it 'changes product attributes' do
          product_user.reload
          expect(product_user.title).not_to eq 'New title' if role == 'user'
          expect(product_user.title).to eq 'New title' if role == 'admin'
        end
      end # locked user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before { product_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { patch :update, id: product_user, product: { title: 'New title'} }
        it 'redirect to home page' do
          expect(response).to redirect_to account_user
        end
        it 'changes product attributes' do
          product_user.reload
          expect(product_user.title).to eq 'New title'
        end
      end # invisible product
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { patch :update, id: product_user, product: { title: 'New title'} }
        it 'redirect to home page' do
          expect(response).to redirect_to account_user
        end
        it 'changes product attributes' do
          product_user.reload
          expect(product_user.title).to eq 'New title'
        end
      end # default
    end # roles: user, admin
  end # PATCH #update

  describe 'DELETE #destroy' do
    it 'visitor invisible user account, redirect to sign in' do
      delete :destroy, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. invisible user account

    it 'visitor visible user account, redirect to sign in' do
      account_user.update_attribute(:visible, true)
      delete :destroy, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. visible user account

    it 'when user wants to delete someone else\'s product' do
      account_admin.update_attribute(:visible, true)
      sign_in user
      delete :destroy, id: product_admin
      expect(response).to redirect_to root_path
    end # role: user. visible acoount user
    
    it 'user delete own product from own locked account' do
      account_user.update_attribute(:locked, true)
      sign_in user
      delete :destroy, id: product_user
      expect(response).to redirect_to root_path
    end # role: user. locked user account

    context 'admin delete user product in locked account' do
      before { product_user }
      before { images_product_user }
      before { orders_product_user }
      before { @request.env['HTTP_REFERER'] = products_path }
      before { sign_in user_admin }
      it 'delete the product from database' do
        expect { delete :destroy, id: product_user }
          .to change(Product, :count).by(-1)
          .and change(Image, :count).by(-2)
          .and change(Order, :count).by(-2)
      end
      it 'redirects to products' do
        delete :destroy, id: product_user
        expect(response).to redirect_to products_path
      end
    end # role: admin. locked user account

    %w(user admin).each do |role|
      context role do
        before { product_user.update_attribute(:visible, false) }
        before { images_product_user }
        before { orders_product_user }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = products_path } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the product from database' do
          expect { delete :destroy, id: product_user }
            .to change(Product, :count).by(-1)
            .and change(Image, :count).by(-2)
            .and change(Order, :count).by(-2)
        end
        it 'redirects to account or products' do
          delete :destroy, id: product_user
          expect(response).to redirect_to account_path(account_user) if role == 'user'
          expect(response).to redirect_to products_path if role == 'admin'
        end
      end # invisible product
    end # user, admin

    %w(user admin).each do |role|
      context role do
        before { product_user }
        before { images_product_user }
        before { orders_product_user }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = products_path } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the product from database' do
          expect { delete :destroy, id: product_user }
            .to change(Product, :count).by(-1)
            .and change(Image, :count).by(-2)
            .and change(Order, :count).by(-2)
        end
        it 'redirects to account or products' do
          delete :destroy, id: product_user
          expect(response).to redirect_to account_path(account_user) if role == 'user'
          expect(response).to redirect_to products_path if role == 'admin'
        end
      end # default
    end # user, admin
  end # DELETE #destroy

  describe 'GET #checked' do
    it 'visitor redirects to sign in' do
      account_user.update_attribute(:visible, true)
      get :checked, id: product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. visible user account

    it 'user redirects to home page' do
      account_user.update_attribute(:visible, true)
      sign_in user
      get :checked, id: product_user
      expect(response).to redirect_to root_path
    end # role: user. visible user account

    context 'admin when locked user account' do
      before do
        account_user.update_attribute(:locked, true)
        @request.env['HTTP_REFERER'] = account_path(account_user)
        sign_in user_admin
      end
      it 'checked user product' do
        expect { get :checked, id: product_user }
          .to change { Product.find(product_user.id).was_changed }
      end
      it 'redirects to products page' do
        get :checked, id: product_user
        expect(response).to redirect_to account_path(account_user)
      end
    end # role: admin. locked user account

    context 'admin when invisible product' do
      before do
        product_user.update_attribute(:visible, false)
        @request.env['HTTP_REFERER'] = account_path(account_user)
        sign_in user_admin
      end
      it 'checked user product' do
        expect { get :checked, id: product_user }
          .to change { Product.find(product_user.id).was_changed }
      end
      it 'redirects to products page' do
        get :checked, id: product_user
        expect(response).to redirect_to account_path(account_user)
      end
    end # role: admin. invisible product

    context 'admin' do
      before do
        @request.env['HTTP_REFERER'] = account_path(account_user)
        sign_in user_admin
      end
      it 'checked user product' do
        expect { get :checked, id: product_user }
          .to change { Product.find(product_user.id).was_changed }
      end
      it 'redirects to products page' do
        get :checked, id: product_user
        expect(response).to redirect_to account_path(account_user)
      end
    end # role: admin. default
  end # checked

  describe 'GET #visible' do
    %w(visitor user).each do |role|
      context role do
        before { account_user.update_attribute(:visible, true) }
        before { sign_in user } if role == 'user'
        before { get :visible, id: product_user }
        it 'redirect to sign in or home page' do
          expect(response).to redirect_to new_user_session_path if role == 'visitor'
          expect(response).to redirect_to root_path if role == 'user'
        end
      end # visible user account
    end # roles: visitor, user

    context 'admin' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      it 'visible user product' do
        expect { get :visible, id: product_user }
        .to change { Product.find(product_user.id).visible }
      end
      it 'redirects to products page' do
        get :visible, id: product_user
        expect(response).to redirect_to products_path
      end
    end # role: admin. locked user account

    context 'admin' do
      before { product_user.update_attribute(:visible, false) }
      before { sign_in user_admin }
      it 'visible user product' do
        expect { get :visible, id: product_user }
        .to change { Product.find(product_user.id).visible }
      end
      it 'redirects to products page' do
        get :visible, id: product_user
        expect(response).to redirect_to products_path
      end
    end # role: admin. invisible product

    context 'admin' do
      before { sign_in user_admin }
      it 'visible user product' do
        expect { get :visible, id: product_user }
          .to change { Product.find(product_user.id).visible }
      end
      it 'redirects to products page' do
        get :visible, id: product_user
        expect(response).to redirect_to products_path
      end
    end # role: admin. default
  end # GET #visible
end # ProductsController
