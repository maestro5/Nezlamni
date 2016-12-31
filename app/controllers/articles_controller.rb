class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :find_account, only: %i(new create)
  before_action :find_article, only: %i(edit update show visible destroy)
  before_action :admin!, only: %i(index visible)
  before_action :visible_account_article!, only: :show
  before_action :admin_or_owner!, only: %i(create edit update destroy)
  
  def index
    @articles = Article.all.order(created_at: :desc).page(params[:page]).per(10)
  end

  def new
    @article = @account.nil? ? Article.new : @account.articles.build
    admin_or_owner!
  end

  def create
    @article =
      @account.nil? ? Article.new(article_params) : @account.articles.build(article_params)
    if @article.save
      @article.check_link!
      redirect_to @article
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      @article.check_link!
      redirect_to @article
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @article.destroy
    if params[:from] == 'show'
      redirect_to @article.account
    else
      redirect_to :back
    end
  end

  def visible
    @article.toggle!(:visible)
    redirect_to articles_path
  end

  private

    def article_params
      params.require(:article).permit(:title, :description, :link)
    end

    def find_article
      @article = Article.find(params[:id])
    end

    def find_account
      @account = Account.find(params[:account_id]) if params[:account_id]
    end

    def visible_account_article!
      return if @article.account.nil? # admin article
      return if (@article.account.visible? || @article.account.user.admin?) && @article.visible?
      return if !current_user.nil? && 
        (current_user.accounts.include?(@article.account) || current_user.admin?)
      redirect_to root_path
    end

    def admin_or_owner!
      return if current_user.admin?
      obj = @account || @article.account
      return if current_user.accounts.include?(obj) && !obj.locked?
      redirect_to root_path
    end
end
