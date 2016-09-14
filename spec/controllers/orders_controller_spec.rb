require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  # orders GET             orders#index
  # new_product_order GET  orders#new
  # product_orders POST    orders#create
  # order GET              orders#show
  # delivered_order GET    orders#delivered

  # roles: visitor, user, admin
  # user account visible, locked
  # product visible
  # order delivered
  
  # Default
  #   user account: visible = false, locked = false
  #   product: visible = true

  let(:user) { create(:user) }
  let(:user_admin) { create(:user_admin) }
  let(:account_user) { user.account }
  let(:account_admin) { user_admin.account }
  let(:product_user) { create(:product, account: account_user) }
  let(:product_admin) { create(:product, account: account_admin) }
  let(:order_product_user) { create(:order, product: product_user, account: account_user) }
  let(:order_product_admin) { create(:order, product: product_admin, account: account_admin) }

  describe 'GET #index' do
    it 'visitor redirect to sign in page' do
      get :index
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. close route
    
    %w(user admin).each do |role|
      context "#{role} when user account invisible" do
        before { order_product_user }
        before { order_product_admin }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of user/all products' do
          expect(assigns(:orders)).not_to be_empty
          expect(assigns(:orders)).to match_array [order_product_user] if role == 'user'
          expect(assigns(:orders)).to match_array Order.all if role == 'admin'
        end
      end # invisible user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context 'user' do
        before { account_user.update_attributes(
          visible: true,
          locked: true
        ) }
        before { order_product_user }
        before { order_product_admin }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of user/all products' do
          expect(assigns(:orders)).not_to be_empty
          expect(assigns(:orders)).to match_array [order_product_user] if role == 'user'
          expect(assigns(:orders)).to match_array Order.all if role == 'admin'
        end
      end # visible, locked user account
    end # roles: user admin

    %w(user admin).each do |role|
      context 'user' do
        before { account_user.update_attribute(:visible, true) }
        before { product_user.update_attribute(:visible, false) }
        before { order_product_user }
        before { order_product_admin }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of user/all products' do
          expect(assigns(:orders)).not_to be_empty
          expect(assigns(:orders)).to match_array [order_product_user] if role == 'user'
          expect(assigns(:orders)).to match_array Order.all if role == 'admin'
        end
      end # invisible product
    end # roles: user, admin

    %w(user admin).each do |role|
      context 'user' do
        before { account_user.update_attribute(:visible, true) }
        before { order_product_user }
        before { order_product_admin }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of user/all products' do
          expect(assigns(:orders)).not_to be_empty
          expect(assigns(:orders)).to match_array [order_product_user] if role == 'user'
          expect(assigns(:orders)).to match_array Order.all if role == 'admin'
        end
      end # visible, unlocked user account; visible product
    end # roles: user, admin
  end # GET #index

  describe 'GET #new' do
    %w(visitor user admin).each do |role|
      context "#{role} order product in invisible account" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user }
        it 'assigns a new Order to @order' do
          expect(assigns(:order)).not_to be_a_new(Order)
        end
        it 'renders new view' do
          expect(response).to redirect_to root_path
        end
      end # invisible user account
    end # roles: visitor, user, admin

    %w(visitor user admin).each do |role|
      context "#{role} order invisible product" do
        before { account_user.update_attribute(:visible, true) }
        before { product_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user }
        it 'assigns a new Order to @order' do
          expect(assigns(:order)).not_to be_a_new(Order)
        end
        it 'renders new view' do
          expect(response).to redirect_to root_path
        end
      end # visible user account; invisible product
    end # roles: visitor, user, admin

    %w(visitor user admin).each do |role|
      context "#{role} order product in locked account" do
        before { account_user.update_attributes(
          visible: true,
          locked: true
        ) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user }
        it 'assigns a new Order to @order' do
          expect(assigns(:order)).to be_a_new(Order)
        end
        it 'renders new view' do
          expect(response).to render_template :new
        end
      end # visible, locked user account
    end # roles: visitor, user, admin

    context 'user order someone else\'s product' do
      before { account_admin.update_attribute(:visible, true) }
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user }
      before { get :new, product_id: product_admin }
      it 'assigns a new Order to @order' do
        expect(assigns(:order)).to be_a_new(Order)
      end
      it 'renders new view' do
        expect(response).to render_template :new
      end
    end # locked user account orders someone else\'s product

    %w(visitor user admin).each do |role|
      context "#{role} order product in visible account" do
        before { account_user.update_attribute(:visible, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user }
        it 'assigns a new Order to @order' do
          expect(assigns(:order)).to be_a_new(Order)
        end
        it 'renders new view' do
          expect(response).to render_template :new
        end
      end # visible, unlocked user account
    end # roles: visitor, user, admin
  end # GET #new

  describe 'POST #create' do
    %w(visitor user admin).each do |role|
      context "#{role} order product in invisible account" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new order in the database' do
          expect { post :create, product_id: product_user, order: attributes_for(:order) }
            .not_to change(Order, :count)
        end
        it 'renders new view' do
          post :create, product_id: product_user, order: attributes_for(:order)
          expect(response).to redirect_to root_path
        end
      end # invisible user account
    end # roles: visitor, user, admin

    %w(visitor user admin).each do |role|
      context "#{role} order invisible product" do
        before { account_user.update_attribute(:visible, true) }
        before { product_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new order in the database' do
          expect { post :create, product_id: product_user, order: attributes_for(:order) }
            .not_to change(Order, :count)
        end
        it 'redirect to order' do
          post :create, product_id: product_user, order: attributes_for(:order)
          expect(response).to redirect_to root_path
        end
      end # invisible product
    end # roles: visitor, user, admin

    %w(visitor user admin).each do |role|
      context "#{role} order product in locked user account" do
        before { account_user.update_attributes(
          visible: true,
          locked: true
        ) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new order in the database' do
          expect { post :create, product_id: product_user, order: attributes_for(:order) }
            .to change(Order, :count).by(1)
        end
        it 'renders new view' do
          post :create, product_id: product_user, order: attributes_for(:order)
          expect(response).to redirect_to order_path(assigns(:order))
        end
      end # visible, locked user account
    end # roles: visitor, user, admin

    context 'user order someone else\'s product' do
      before { account_admin.update_attribute(:visible, true) }
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user }
      it 'saves the new order in the database' do
        expect { post :create, product_id: product_admin, order: attributes_for(:order) }
        .to change(Order, :count).by(1)
      end
      it 'renders new view' do
        post :create, product_id: product_admin, order: attributes_for(:order)
        expect(response).to redirect_to order_path(assigns(:order))
      end
    end # locked user account orders someone else\'s product

    %w(visitor user admin).each do |role|
      context "#{role} order product in visible account" do
        before { account_user.update_attribute(:visible, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new order in the database' do
          expect { post :create, product_id: product_user, order: attributes_for(:order) }
            .to change(Order, :count).by(1)
        end
        it 'renders new view' do
          post :create, product_id: product_user, order: attributes_for(:order)
          expect(response).to redirect_to order_path(assigns(:order))
        end
      end # visible, unlocked user account; visible product
    end # roles: visitor, user, admin
  end # POST #create

  describe 'GET #show' do
    %w(visitor user admin).each do |role|
      context "#{role} close routes" do
        before { account_user.update_attribute(:visible, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :show, id: order_product_user }
        it 'renders show order view' do
          expect(response).to render_template :show
        end
        it 'populates an order' do
          expect(assigns(:order)).to be_nil
        end
      end # close routes
    end # roles: visitor, user, admin
  end # GET #show

  describe 'GET #delivered' do
    it 'visitor redirect to home page' do
      get :delivered, id: order_product_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor. close route

    %w(user admin).each do |role|
      context role do
        before { order_product_user.update_attribute(:delivered, false) }
        before { @request.env['HTTP_REFERER'] = orders_path }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delivered order' do
          expect { get :delivered, id: order_product_user }
            .to change { Order.find(order_product_user.id).delivered }
            .and change { Account.find(account_user.id).backers }.by(1)
            .and change { Account.find(account_user.id).collected }.by(+777)
            .and change { Product.find(product_user.id).backers }.by(1)
        end
        it 'redirects to orders page' do
          get :delivered, id: order_product_user
          expect(response).to redirect_to orders_path
        end
      end # delivered: false
    end # roles: user, admin

    %w(user admin).each do |role|
      context role do
        before { order_product_user.update_attribute(:delivered, true) }
        before { account_user.update_attribute(:backers, 1) }
        before { @request.env['HTTP_REFERER'] = orders_path }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delivered order' do
          expect { get :delivered, id: order_product_user }
            .to change { Order.find(order_product_user.id).delivered }
            .and change { Account.find(account_user.id).backers }.by(-1)
            .and change { Account.find(account_user.id).collected }.by(-777)
            .and change { Product.find(product_user.id).backers }.by(-1)
        end
        it 'redirects to orders page' do
          get :delivered, id: order_product_user
          expect(response).to redirect_to orders_path
        end
      end # delivered: true
    end # roles: user, admin

    it 'user when locked user account' do
      account_user.update_attribute(:locked, true)
      @request.env['HTTP_REFERER'] = orders_path
      sign_in user
      get :delivered, id: order_product_user

      expect(response).to redirect_to root_path
    end # role: user. when locked user account, delivered: false

    # !!! ================================================= !!!
    it 'user when delivered someone else\'s order' do
      account_admin.update_attribute(:visible, true)
      @request.env['HTTP_REFERER'] = orders_path
      sign_in user
      get :delivered, id: order_product_admin
      expect(response).to redirect_to root_path
    end # role: user. when delivered someone else\'s order
    # !!! ================================================= !!!

    context 'admin when locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { @request.env['HTTP_REFERER'] = orders_path }
      before { sign_in user_admin }
      it 'delivered order' do
        expect { get :delivered, id: order_product_user }
          .to change { Order.find(order_product_user.id).delivered }
          .and change { Account.find(account_user.id).backers }.by(1)
          .and change { Account.find(account_user.id).collected }.by(+777)
          .and change { Product.find(product_user.id).backers }.by(1)
      end
      it 'redirects to orders page' do
        get :delivered, id: order_product_user
        expect(response).to redirect_to orders_path
      end
    end # role: admin. when locked user account, delivered: false

    it 'user when locked user account' do
      account_user.update_attribute(:locked, true)
      order_product_user.update_attribute(:delivered, true)
      @request.env['HTTP_REFERER'] = orders_path
      sign_in user
      get :delivered, id: order_product_user
      expect(response).to redirect_to root_path
    end # role: user. when locked user account, delivered: true

    context 'admin when locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { order_product_user.update_attribute(:delivered, true) }
      before { @request.env['HTTP_REFERER'] = orders_path }
      before { sign_in user_admin }
      it 'delivered order' do
        expect { get :delivered, id: order_product_user }
          .to change { Order.find(order_product_user.id).delivered }
          .and change { Account.find(account_user.id).backers }.by(-1)
          .and change { Account.find(account_user.id).collected }.by(-777)
          .and change { Product.find(product_user.id).backers }.by(-1)
      end
      it 'redirects to orders page' do
        get :delivered, id: order_product_user
        expect(response).to redirect_to orders_path
      end
    end # role: admin. when locked user account, delivered: true
  end # GET #delivered
end # OrdersController
