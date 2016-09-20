class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :admin!, only: :products

  def home
    @accounts = Account.where(visible: true).order(deadline_on: :asc).page(params[:page]).per(9)

    account_articles = Account.where(visible: true).includes(:articles).where(articles: { visible: true }).limit(9)
    user_admin = User.find_by(admin: true)
    accounts_ids = account_articles.distinct.ids
    accounts_ids = accounts_ids << user_admin.account.id if user_admin
    @articles = Article.where(account: accounts_ids, visible: true).order(created_at: :desc).limit(9)
    @results = @accounts + @articles
  end

  def products
    @products = Product.all.order(created_at: :desc).page(params[:page]).per(10)
  end
end # PagesController
