require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  # account_images GET            images#index
  #   POST                        images#create
  # new_account_image GET         images#new
  # product_images GET            images#index
  #   POST                        images#create
  # new_product_image GET         images#new
  # image DELETE                  images#destroy
  # set_avatar_account_image GET  images#set_avatar
  # set_avatar_product_image GET  images#set_avatar

  # roles: visitor, user, admin
  # user account: locked
  
  # Default
  #   user account: visible = false, locked = false

  let(:user) { create(:user) }
  let(:user_admin) { create(:user_admin) }
  let(:account_user) { create(:account, user: user) }
  let(:account_admin) { create(:account, user: user_admin) }
  let(:product_user) { create(:product, account: account_user) }
  let(:image_account_user) { create(:image, imageable: account_user) }
  let(:image_account_admin) { create(:image, imageable: account_admin) }
  let(:images_account_user) { create_list(:image, 2, imageable: account_user) }
  let(:image_product_user) { create(:image, imageable: product_user) }
  let(:image_product_admin) { create(:image, imageable: product_admin) }
  let(:images_product_user) { create_list(:image, 2, imageable: product_user) }
  let(:product_admin) { create(:product, account: account_admin) }
  let(:images_account_admin) { create_list(:image, 2, imageable: account_admin) }
  let(:images_product_admin) { create_list(:image, 2, imageable: product_admin) }
  
  describe 'GET #index' do
    context 'visitor' do
      it 'when account images, redirect to sign in page' do
        get :index, account_id: account_user
        expect(response).to redirect_to new_user_session_path
      end
      it 'when product images, redirect to sign in page' do
        get :index, product_id: product_user
        expect(response).to redirect_to new_user_session_path
      end
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} account images" do
        before { images_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index, account_id: account_user }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all account images' do
          expect(assigns(:images)).not_to be_empty
          expect(assigns(:images)).to match_array images_account_user
        end
      end # account images
      context "#{role} product images" do
        before { images_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index, product_id: product_user }
        it 'renders index view' do
          expect(response).to render_template :index
        end
        it 'populates an array of all product images' do
          expect(assigns(:images)).not_to be_empty
          expect(assigns(:images)).to match_array images_product_user
        end
      end # product images
    end # roles: user, admin. default

    %w(user admin).each do |role|      
      context "#{role} account images when locked user account" do
        before { account_user.update_attribute(:locked, true) }
        before { images_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index, account_id: account_user }
        it 'renders indes view or redirect to home page' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :index if role == 'admin'
        end
        it 'populates a nil or images array' do
          expect(assigns(:images)).to be_nil if role == 'user'
          expect(assigns(:images)).to match_array images_account_user if role == 'admin'
        end
      end # account images
      context "#{role} product images when locked user account" do
        before { account_user.update_attribute(:locked, true) }
        before { images_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :index, product_id: product_user }
        it 'renders indes view or redirect to home page' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :index if role == 'admin'
        end
        it 'populates a nil or images array' do
          expect(assigns(:images)).to be_nil if role == 'user'
          expect(assigns(:images)).to match_array images_product_user if role == 'admin'
        end
      end # product images
    end # roles: user, admin. locked user account

    context 'user someone else\'s account images' do
      before { images_account_admin }
      before { sign_in user }
      before { get :index, account_id: account_admin }
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
      it 'populates a nil images' do
        expect(assigns(:images)).to be_nil
      end
    end # role: user. default. someone else's account images

    context 'user someone else\'s product images' do
      before { images_product_admin }
      before { sign_in user }
      before { get :index, product_id: product_admin }
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
      it 'populates a nil images' do
        expect(assigns(:images)).to be_nil
      end
    end # role: user. default. someone else's product images
  end # GET #index

  describe 'POST #create' do
    context 'visitor' do
      it 'when account images, redirect to sign in page' do
        post :create, account_id: account_user, image: attributes_for(:image)
        expect(response).to redirect_to new_user_session_path
      end # account
      it 'when product images, redirect to sign in page' do
        post :create, product_id: product_user, image: attributes_for(:image)
        expect(response).to redirect_to new_user_session_path
      end # product
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} account images" do
        before { @request.env['HTTP_REFERER'] = account_path(account_user) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new image in the database' do
          expect { post :create, account_id: account_user, image: attributes_for(:image) }
            .to change(Image, :count).by(1)
        end
        it 'redirect to account page' do
          post :create, account_id: account_user, image: attributes_for(:image)
          expect(response).to redirect_to account_path(account_user)
        end
      end # account images
      context "#{role} product images" do
        before { @request.env['HTTP_REFERER'] = product_path(product_user) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new image in the database' do
          expect { post :create, product_id: product_user, image: attributes_for(:image) }
            .to change(Image, :count).by(1)
        end
        it 'redirect to product page' do
          post :create, product_id: product_user, image: attributes_for(:image)
          expect(response).to redirect_to product_path(product_user)
        end
      end # product images
    end # roles: user, admin. default

    %w(user admin).each do |role|
      context "#{role} account images" do
        before { account_user.update_attribute(:locked, true) }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new image in the database' do
          expect { post :create, account_id: account_user, image: attributes_for(:image) }
            .not_to change(Image, :count) if role == 'user'
            expect { post :create, account_id: account_user, image: attributes_for(:image) }
            .to change(Image, :count).by(1) if role == 'admin'
        end
        it 'redirect to account page' do
          post :create, account_id: account_user, image: attributes_for(:image)
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to account_path(account_user) if role == 'admin'
        end
      end # account images
      context "#{role} product images" do
        before { account_user.update_attribute(:locked, true) }
        before { @request.env['HTTP_REFERER'] = product_path(product_user) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new image in the database' do
          expect { post :create, product_id: product_user, image: attributes_for(:image) }
            .not_to change(Image, :count) if role == 'user'
          expect { post :create, product_id: product_user, image: attributes_for(:image) }
            .to change(Image, :count).by(1) if role == 'admin'
        end
        it 'redirect to product page' do
          post :create, product_id: product_user, image: attributes_for(:image)
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to product_path(product_user) if role == 'admin'
        end
      end # product images
    end # roles: user, admin. locked user account

    context 'user someone else\'s account image' do
      before { @request.env['HTTP_REFERER'] = account_path(account_admin) }
      before { sign_in user }
      it 'saves the new image in the database' do
        expect { post :create, account_id: account_admin, image: attributes_for(:image) }
          .not_to change(Image, :count)
      end
      it 'redirect to account page' do
        post :create, account_id: account_admin, image: attributes_for(:image)
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's account images

    context 'user someone else\'s product image' do
      before { @request.env['HTTP_REFERER'] = product_path(product_admin) }
      before { sign_in user }
      it 'saves the new image in the database' do
        expect { post :create, product_id: product_admin, image: attributes_for(:image) }
          .not_to change(Image, :count)
      end
      it 'redirect to product page' do
        post :create, product_id: product_admin, image: attributes_for(:image)
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's product images
  end # POST #index

  describe 'GET #new' do
    context 'visitor' do
      it 'when account images, redirect to sign in page' do
        get :new, account_id: account_user
        expect(response).to redirect_to new_user_session_path
      end # account
      it 'when product images, redirect to sign in page' do
        get :new, product_id: product_user
        expect(response).to redirect_to new_user_session_path
      end # product
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} account images" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, account_id: account_user}
        it 'assigns a new Image to @image' do
          expect(assigns(:image)).to be_a_new(Image)
        end
        it 'renders new view' do
          expect(response).to render_template :new
        end
      end # account images
      context "#{role} product images" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user}
        it 'assigns a new Image to @image' do
          expect(assigns(:image)).to be_a_new(Image)
        end
        it 'renders new view' do
          expect(response).to render_template :new
        end
      end # product images
    end # roles: user, admin. default

    %w(user admin).each do |role|
      context "#{role} account images" do
        before { account_user.update_attribute(:locked, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, account_id: account_user}
        it 'assigns a new Image to @image' do
          expect(assigns(:image)).to be_nil if role == 'user'
          expect(assigns(:image)).to be_a_new(Image) if role == 'admin'
        end
        it 'redirect to home page or renders new view' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :new if role == 'admin'
        end
      end # account images
      context "#{role} product images" do
        before { account_user.update_attribute(:locked, true) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, product_id: product_user}
        it 'assigns a new Image to @image' do
          expect(assigns(:image)).to be_nil if role == 'user'
          expect(assigns(:image)).to be_a_new(Image) if role == 'admin'
        end
        it 'redirect to home page or renders new view' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :new if role == 'admin'
        end
      end # product images
    end # roles: user, admin. locked user account

    context 'user someone else\'s account image' do
      before { sign_in user }
      before { get :new, account_id: account_admin}
      it 'assigns a new Image to @image' do
        expect(assigns(:image)).to be_nil
      end
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's account images

    context 'user someone else\'s product images' do
      before { sign_in user }
      before { get :new, product_id: product_admin}
      it 'assigns a new Image to @image' do
        expect(assigns(:image)).to be_nil
      end
      it 'redirect to home page or renders new view' do
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's product images
  end # GET #new

  describe 'DELETE #destroy' do
    context 'visitor' do
      it 'when account images, redirect to sign in page' do
        delete :destroy, id: image_account_user
        expect(response).to redirect_to new_user_session_path
      end # account
      it 'when product images, redirect to sign in page' do
        delete :destroy, id: image_product_user
        expect(response).to redirect_to new_user_session_path
      end # product
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} account image" do
        before { @request.env['HTTP_REFERER'] = account_images_path(account_user) }
        before { image_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the account image from database' do
          expect { delete :destroy, id: image_account_user }
            .to change(Image, :count).by(-1)
        end
        it 'redirects to account images' do
          delete :destroy, id: image_account_user
          expect(response).to redirect_to account_images_path(account_user)
        end
      end # account images
      context "#{role} product images" do
        before { @request.env['HTTP_REFERER'] = product_images_path(product_user) }
        before { image_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the account image from database' do
          expect { delete :destroy, id: image_product_user }
            .to change(Image, :count).by(-1)
        end
        it 'redirects to account images' do
          delete :destroy, id: image_product_user
          expect(response).to redirect_to product_images_path(product_user)
        end
      end # product images
    end # roles: user, admin. default

    %w(user admin).each do |role|
      context "#{role} account image" do
        before { account_user.update_attribute(:locked, true) }
        before { @request.env['HTTP_REFERER'] = account_images_path(account_user) }
        before { image_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the account image from database' do
          expect { delete :destroy, id: image_account_user }
            .not_to change(Image, :count) if role == 'user'
          expect { delete :destroy, id: image_account_user }
            .to change(Image, :count).by(-1) if role == 'admin'
        end
        it 'redirects to home page or account images' do
          delete :destroy, id: image_account_user
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to account_images_path(account_user) if role == 'admin'
        end
      end # account images
      context "#{role} product images" do
        before { account_user.update_attribute(:locked, true) }
        before { @request.env['HTTP_REFERER'] = product_images_path(product_user) }
        before { image_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the account image from database' do
          expect { delete :destroy, id: image_product_user }
            .not_to change(Image, :count) if role == 'user'
          expect { delete :destroy, id: image_product_user }
            .to change(Image, :count).by(-1) if role == 'admin'
        end
        it 'redirects to home page or account images' do
          delete :destroy, id: image_product_user
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to product_images_path(product_user) if role == 'admin'
        end
      end # product images
    end # roles: user, admin. locked user account

    context 'user someone else\'s account image' do
      before { @request.env['HTTP_REFERER'] = account_images_path(account_admin) }
      before { image_account_admin }
      before { sign_in user }
      it 'delete the account image from database' do
        expect { delete :destroy, id: image_account_admin }
          .not_to change(Image, :count)
      end
      it 'redirects to home page or account images' do
        delete :destroy, id: image_account_admin
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's account images

    context 'user someone else\'s product images' do
      before { @request.env['HTTP_REFERER'] = product_images_path(product_admin) }
      before { image_product_admin }
      before { sign_in user }
      it 'delete the account image from database' do
        expect { delete :destroy, id: image_product_admin }
          .not_to change(Image, :count)
      end
      it 'redirects to home page or account images' do
        delete :destroy, id: image_product_admin
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's product images
  end # DELETE #destroy

  describe 'GET #set_avatar' do
    context 'visitor' do
      it 'when account images, redirect to sign in page' do
        get :set_avatar, account_id: account_user, id: image_account_user
        expect(response).to redirect_to new_user_session_path
      end # account
      it 'when product images, redirect to sign in page' do
        get :set_avatar, product_id: product_user, id: image_product_user
        expect(response).to redirect_to new_user_session_path
      end # product
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} account image" do
        before { image_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :set_avatar, account_id: account_user, id: image_account_user }
        it 'set account avatar in database' do
          account_user.reload
          expect(account_user.avatar_url).not_to be_nil
          expect(account_user.avatar_url).to eq image_account_user.image_url
        end
        it 'redirect to account edit page' do
          expect(response).to redirect_to edit_account_path(account_user)
        end
      end # account images
      context "#{role} product images" do
        before { image_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :set_avatar, product_id: product_user, id: image_product_user }
        it 'set product avatar in database' do
          product_user.reload
          expect(product_user.avatar_url).not_to be_nil
          expect(product_user.avatar_url).to eq image_product_user.image_url
        end
        it 'redirect to product edit page' do
          expect(response).to redirect_to edit_product_path(product_user)
        end
      end # product images
    end # roles: user, admin. default

    %w(user admin).each do |role|
      context "#{role} account image" do
        before { account_user.update_attribute(:locked, true) }
        before { image_account_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :set_avatar, account_id: account_user, id: image_account_user }
        it 'set account avatar in database' do
          account_user.reload
          expect(account_user.avatar_url).to be_nil if role == 'user'
          expect(account_user.avatar_url).to eq image_account_user.image_url if role == 'admin'
        end
        it 'redirect to account edit page or home page' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to edit_account_path(account_user) if role == 'admin'
        end
      end # account images
      context "#{role} product images" do
        before { account_user.update_attribute(:locked, true) }
        before { image_product_user }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :set_avatar, product_id: product_user, id: image_product_user }
        it 'set product avatar in database' do
          product_user.reload
          expect(product_user.avatar_url).to be_nil if role == 'user'
          expect(product_user.avatar_url).to eq image_product_user.image_url if role == 'admin'
        end
        it 'redirect to product edit page or home page' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to redirect_to edit_product_path(product_user) if role == 'admin'
        end
      end # product images
    end # roles: user, admin. locked user account

    context 'user someone else\'s set avatar account image' do
      before { image_account_admin }
      before { sign_in user }
      before { get :set_avatar, account_id: account_admin, id: image_account_admin }
      it 'not set account avatar in database' do
        account_admin.reload
        expect(account_admin.avatar_url).to be_nil
      end
      it 'redirect to home page' do
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's account images

    context 'user someone else\'s set avatar product image' do
      before { image_product_admin }
      before { sign_in user }
      before { get :set_avatar, product_id: product_admin, id: image_product_admin }
      it 'set product avatar in database' do
        product_admin.reload
        expect(product_user.avatar_url).to be_nil
      end
      it 'redirect to product edit page or home page' do
        expect(response).to redirect_to root_path
      end
    end # role: user. default. someone else's product images
  end # GET #set_avatar
end # ImagesController
