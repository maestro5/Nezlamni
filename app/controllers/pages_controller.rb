class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :admin!, only: :products

  def home
    @accounts = Account.where(visible: true).order(deadline_on: :asc)
    @articles = Article.where(account: @accounts, visible: true).order(created_at: :desc)
  end

  def products
    @products = Product.all.order(created_at: :desc).page(params[:page]).per(10)
  end
end # PagesController
