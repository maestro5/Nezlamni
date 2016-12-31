class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  before_action :admin!, only: :products

  def home
    @accounts = Account.where(visible: true).order(deadline_on: :asc).page(params[:page]).per(9)
    @articles = 
      Article
        .joins("LEFT OUTER JOIN accounts ON accounts.id = articles.account_id")
        .where('(accounts.visible=? OR articles.account_id IS ?) AND articles.visible=?', true, nil, true)
        .order(created_at: :desc)
        .limit(9)
    @results = @accounts + @articles
  end

  def products
    @products =
      Product
        .where(default: false)
        .order(account_id: :asc, created_at: :desc)
        .page(params[:page])
        .per(10)
  end
end # PagesController
