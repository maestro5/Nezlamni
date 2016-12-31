require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # users GET    users#index
  # user  DELETE users#destroy

  # roles: visitor, user, admin

  let!(:user_admin) { create :user_admin }
  let!(:user)       { create :user }

  context 'visitor' do
    describe 'GET #index' do
      it 'redirect to sign_in page' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'DELETE #destroy' do
      it 'redirect to sign_in page' do
        delete :destroy, id: user_admin.id
        expect(response).to redirect_to new_user_session_path
      end
    end
  end # visitor

  context 'user' do
    before { sign_in user }

    describe 'GET #index' do
      it 'redirect to sign_in page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'DELETE #destroy' do
      it 'redirect to sign_in page' do
        delete :destroy, id: user_admin
        expect(response).to redirect_to root_path
      end
    end
  end # user

  context 'admin' do
    let!(:account_1)   { create :account, user: user }
    let!(:account_2)   { create :account, user: user }
    let!(:images)   { create_list :image, 2, imageable: account_1 }
    let!(:image)    { create :image, imageable: account_2 }
    let!(:product)  { create :product, account: account_1 }
    let!(:products) { create_list :product, 2, account: account_2 }
    let!(:article)  { create :article, account: account_1 }
    let!(:articles) { create_list :article, 2, account: account_2 }
    let!(:orders)  { create_list :order, 2, account: account_1 }
    let!(:order)   { create :order, account: account_2 }
    let!(:order_p) { create :order, product: product }
    let!(:image_p) { create :image, imageable: product }
    let!(:users)      { create_list :user, 8 }

    before { sign_in user_admin }

    describe 'GET #index' do
      before { get :index }
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of all users' do
        expect(assigns(:users)).not_to be_empty
        expect(assigns(:users))
          .to match_array User.order(created_at: :desc).limit(9)
      end
    end

    describe 'DELETE #destroy' do
      it 'destroy user and his data' do
        expect { delete :destroy, id: user}
          .to change(User, :count).by(-1)
          .and change(Account, :count).by(-2)
          .and change(Image, :count).by(-4)    # + 1 product image
          .and change(Product, :count).by(-5)  # + 2 default products
          .and change(Article, :count).by(-3)
          .and change(Order, :count).by(-4)
      end
    end
  end # admin
end # UsersController
