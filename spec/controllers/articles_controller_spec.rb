require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  # articles GET             articles#index
  # new_account_article GET  articles#new
  # account_articles POST    articles#create
  # edit_article GET         articles#edit
  # article GET              articles#show
  #   PATCH                  articles#update
  #   PUT                    articles#update
  #   DELETE                 articles#destroy
  # visible_article GET      articles#visible

  # roles: visitor, user, admin
  # user account visible, locked
  # article visible
  
  # Default
  #   user account: visible = false, locked = false
  #   article: visible = true

  let(:user) { create(:user) }
  let(:user_admin) { create(:user_admin) }
  let(:account_user) { create(:account, user: user) }
  let(:account_admin) { create(:account, user: user_admin) }
  let(:article_user) { create(:article, account: account_user) }
  let(:article_admin) { create(:article, account: account_admin) }

  describe 'GET #index' do
    %w(visitor user).each do |role|
      context role do
        before { sign_in user } if role == 'user'
        before { get :index }
        it 'redirect to sign in or home page' do
          expect(response).to redirect_to new_user_session_path if role == 'visitor'
          expect(response).to redirect_to root_path if role == 'user'
        end
      end # close routes
    end # roles: visitor, user

    context 'admin include invisible articles' do
      before do
        article_user.update_attribute(:visible, false)
        create_list(:article, 5, account: account_user, visible: false)
        create_list(:article, 7, account: account_admin)
        article_admin
        sign_in user_admin
        get :index
      end
      it 'renders index view' do
        expect(response).to render_template :index
      end
      it 'populates an array of all articles' do
        expect(assigns(:articles)).not_to be_empty
        expect(assigns(:articles)).to match_array Article.all.order(created_at: :desc).limit(10)
      end
    end # role: admin
  end # GET #index

  describe 'GET #new' do
    it 'visitor renders sign in view' do
      get :new, account_id: account_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    %w(user admin).each do |role|
      context "#{role} locked user account" do
        before do
          account_user.update_attribute(:locked, true)
          sign_in user if role == 'user'
          sign_in user_admin if role == 'admin'
          get :new, account_id: account_user
        end
        it 'assigns a new Article to @article' do
          expect(assigns(:article)).to be_a_new(Article)
        end
        it 'redirect to home page or renders new view' do
          expect(response).to redirect_to root_path if role == 'user'
          expect(response).to render_template :new if role == 'admin'
        end
      end # locked user account
    end # roles: user, admin

    it 'user get new for someone else\'s account' do
      sign_in user
      get :new, account_id: account_admin
      expect(response).to redirect_to root_path
    end # role: user. someone else\'s account

    %w(user admin).each do |role|
      context "#{role} unlocked user account" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :new, account_id: account_user }
        it 'assigns a new Article to @article' do
          expect(assigns(:article)).to be_a_new(Article)
        end
        it 'redirect to home page or renders new view' do
          expect(response).to render_template :new
        end
      end # default
    end # roles: user, admin
  end # GET #new

  describe 'POST #create' do
    it 'visitor redirect to sign in' do
      post :create, account_id: account_user, article: attributes_for(:article)
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    it 'user locked user account redirect to home page' do
      account_user.update_attribute(:locked, true)
      sign_in user
      post :create, account_id: account_user, article: attributes_for(:article)
      expect(response).to redirect_to root_path
    end # role: user. locked user account

    context 'admin locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      it 'saves the new article in the database' do
        expect { post :create, account_id: account_user, article: attributes_for(:article) }
          .to change(Article, :count).by(1)
      end
      it 'renders show view' do
        post :create, account_id: account_user, article: attributes_for(:article)
        expect(response).to redirect_to article_path(assigns(:article))
      end
    end # role: admin. locked user account

    it 'user create article for someone else\'s account' do
      sign_in user
      post :create, account_id: account_admin, article: attributes_for(:article)
      expect(response).to redirect_to root_path
    end # role: user. someone else\'s account

    %w(user admin).each do |role|
      context "#{role} unlocked user account" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'saves the new article in the database' do
          expect { post :create, account_id: account_user, article: attributes_for(:article) }
            .to change(Article, :count).by(1)
        end
        it 'renders show view' do
          post :create, account_id: account_user, article: attributes_for(:article)
          expect(response).to redirect_to article_path(assigns(:article))
        end
      end # default
    end # roles: user, admin
  end # GET #create

  describe 'GET #edit' do
    it 'visitor renders sign in view' do
      get :edit, id: article_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    it 'user locked user account redirect to home page' do
      account_user.update_attribute(:locked, true)
      sign_in user
      get :edit, id: article_user
      expect(response).to redirect_to root_path
    end # role: user. locked user account

    context 'admin locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      before { get :edit, id: article_user }
      it 'populates an article' do
        expect(assigns(:article)).to eq article_user
      end
      it 'renders edit view' do
        expect(response).to render_template :edit
      end
    end # role: admin. locked user account

    it 'user get edit for someone else\'s article' do
      sign_in user
      get :edit, id: article_admin
      expect(response).to redirect_to root_path
    end # role: user. someone else\'s article

    %w(user admin).each do |role|
      context "#{role} invisible article" do
        before { article_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :edit, id: article_user }
        it 'populates an article' do
          expect(assigns(:article)).to eq article_user
        end
        it 'renders edit view' do
          expect(response).to render_template :edit
        end
      end # invisible article
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} user account unlocked, article visible" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :edit, id: article_user }
        it 'populates an article' do
          expect(assigns(:article)).to eq article_user
        end
        it 'renders edit view' do
          expect(response).to render_template :edit
        end
      end # default
    end # roles: user, admin
  end # GET #edit

  describe 'PATCH #update' do
    it 'visitor renders sign in view' do
      patch :update, id: article_user
      expect(response).to redirect_to new_user_session_path
    end # role: visitor

    it 'user locked user account redirect to home page' do
      account_user.update_attribute(:locked, true)
      sign_in user
      patch :update, id: article_user
      expect(response).to redirect_to root_path
    end # role: user. locked user account

    context 'admin locked user account' do
      before { account_user.update_attribute(:locked, true) }
      before { sign_in user_admin }
      before { patch :update, id: article_user, article: { title: 'New title' } }
      it 'saves the edited article in the database' do
        article_user.reload
        expect(article_user.title).to eq 'New title'
      end
      it 'renders article show' do
        expect(response).to redirect_to article_user
      end
    end # role: admin. locked user account

    it 'user update article for someone else\'s account' do
      sign_in user
      patch :update, id: article_admin, article: { title: 'New title' }
      expect(response).to redirect_to root_path
    end # role: user. someone else\'s article

    %w(user admin).each do |role|
      context "#{role} invisible article" do
        before { article_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { patch :update, id: article_user, article: { title: 'New title' } }
        it 'saves the edited article in the database' do
          article_user.reload
          expect(article_user.title).to eq 'New title'
        end
        it 'renders article show' do
          expect(response).to redirect_to article_user
        end
      end # invisible article
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} user account unlocked, article visible" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { patch :update, id: article_user, article: { title: 'New title' } }
        it 'saves the edited article in the database' do
          article_user.reload
          expect(article_user.title).to eq 'New title'
        end
        it 'renders article show' do
          expect(response).to redirect_to article_user
        end
      end # default
    end # roles: user, admin
  end # GET #update

  describe 'GET #show' do
    it 'visitor not available invisible user account articles' do
      get :show, id: article_user
      expect(response).to redirect_to root_path
    end # role: visitor. invisible user account

    it 'visitor not available invisible article' do
      account_user.update_attribute(:visible, true)
      article_user.update_attribute(:visible, false)
      get :show, id: article_user
      expect(response).to redirect_to root_path
    end # role: visitor. invisible article

    it 'user not available someone else\'s invisible article' do
      article_admin.update_attribute(:visible, false)
      sign_in user
      get :show, id: article_admin
      expect(response).to redirect_to root_path
    end # role: user. invisible article

    %w(user admin).each do |role|
      context "#{role} available invisible account and invisible article" do
        before { article_user.update_attribute(:visible, false) }
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { get :show, id: article_user }
        it 'renders show view' do
          expect(response).to render_template :show
        end
        it 'populates an article' do
          expect(assigns(:article)).to eq article_user
        end
      end # invisible user account; invisible artticle
    end # roles: user, admin

    it 'user not available someone else\'s invisible article' do
      account_admin.update_attribute(:visible, true)
      article_admin.update_attribute(:visible, false)
      get :show, id: article_admin
      expect(response).to redirect_to root_path
    end # role: user. invisible article

    %w(visitor user admin).each do |role|
      context "#{role} user account visible, article visible" do
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        before { account_user.update_attribute(:visible, true) }
        before { get :show, id: article_user }
        it 'renders show view' do
          expect(response).to render_template :show
        end
        it 'populates an article' do
          expect(assigns(:article)).to eq article_user
        end
      end # visible user account; visible artticle
    end # roles: visitor, user, admin
  end # GET #show

  describe 'DELETE #destroy' do
    context 'visitor redirect to sign in page' do
      before { account_user.update_attribute(:visible, true) }
      before { article_user }
      it 'not deleted article from database' do
        expect { delete :destroy, id: article_user }
          .not_to change(Article, :count)
      end
      it 'redirect to sign in page' do
        delete :destroy, id: article_user
        expect(response).to redirect_to new_user_session_path
      end
    end # role: visitor

    context 'user deleted someone else\'s article' do
      before { account_admin.update_attribute(:visible, true) }
      before { article_admin }
      before { sign_in user }
      it 'not deleted article from database' do
        expect { delete :destroy, id: article_admin }
          .not_to change(Article, :count)
      end
      it 'redirect to home page' do
        delete :destroy, id: article_admin
        expect(response).to redirect_to root_path
      end
    end # role: user. someone else\'s account

    %w(user admin).each do |role|
      context "#{role} when invisible user account" do
        before { article_user }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = articles_path } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account or articles' do
          delete :destroy, id: article_user
          expect(response).to redirect_to account_path(account_user) if role == 'user'
          expect(response).to redirect_to articles_path if role == 'admin'
        end
      end # default
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} when invisible user account" do
        before { article_user }
        before { @request.env['HTTP_REFERER'] = article_path(article_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account' do
          delete :destroy, id: article_user, from: 'show' if role == 'user'
          delete :destroy, id: article_user if role == 'admin'
          expect(response).to redirect_to account_path(account_user)
        end
      end # default. user from article, admin from user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} when invisible article" do
        before { article_user.update_attribute(:visible, false) }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = articles_path } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account or products' do
          delete :destroy, id: article_user
          expect(response).to redirect_to account_path(account_user) if role == 'user'
          expect(response).to redirect_to articles_path if role == 'admin'
        end
      end # invisible article
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} when invisible article" do
        before { article_user.update_attribute(:visible, false) }
        before { @request.env['HTTP_REFERER'] = article_path(article_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account or products' do
          delete :destroy, id: article_user, from: 'show' if role == 'user'
          delete :destroy, id: article_user if role == 'admin'
          expect(response).to redirect_to account_path(account_user)
        end
      end # invisible article
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} when invisible article" do
        before { account_user.update_attribute(:visible, true) }
        before { article_user }
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = articles_path } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account or products' do
          delete :destroy, id: article_user
          expect(response).to redirect_to account_path(account_user) if role == 'user'
          expect(response).to redirect_to articles_path if role == 'admin'
        end
      end # visible user account
    end # roles: user, admin

    %w(user admin).each do |role|
      context "#{role} when invisible article" do
        before { account_user.update_attribute(:visible, true) }
        before { article_user }
        before { @request.env['HTTP_REFERER'] = article_path(article_user) } if role == 'user'
        before { @request.env['HTTP_REFERER'] = account_path(account_user) } if role == 'admin'
        before { sign_in user } if role == 'user'
        before { sign_in user_admin } if role == 'admin'
        it 'delete the article from database' do
          expect { delete :destroy, id: article_user }
            .to change(Article, :count).by(-1)
        end
        it 'redirects to account or products' do
          delete :destroy, id: article_user, from: 'show' if role == 'user'
          delete :destroy, id: article_user if role == 'admin'
          expect(response).to redirect_to account_path(account_user)
        end
      end # visible user account
    end # roles: user, admin
  end # GET #destroy

  describe 'GET #visible' do
    %w(visitor user).each do |role|
      it 'redirect to home page' do
        sign_in user if role == 'user'
        get :visible, id: article_user
        expect(response).to redirect_to new_user_session_path if role == 'visitor'
        expect(response).to redirect_to root_path if role == 'user'
      end
    end # roles: visitor, user

    context 'admin' do
      before { sign_in user_admin }
      it 'change visible article in database' do
        expect { get :visible, id: article_user }
          .to change { Article.find(article_user.id).visible }
      end
      it 'redirect to articles' do
        get :visible, id: article_user
        expect(response).to redirect_to articles_path
      end
    end # role: admin
  end # GET #visible
end # ArticlesController
