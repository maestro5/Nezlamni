class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :find_account, only: [:new, :create]
  before_action :find_article, only: [:edit, :update, :show, :visible, :destroy]

  def index
    @articles = Article.all.order(created_at: :desc)
    @account  = current_user.account
  end

  def new
    @article = @account.articles.build 
  end

  def create
    @article = @account.articles.build(article_params)
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

  def visible
    @article.toggle!(:visible)
    redirect_to articles_path
  end

  def destroy
    @article.destroy
    redirect_to :back
  end

  private

  def article_params
    params.require(:article).permit(:title, :description, :link)
  end

  def find_article
    @article = Article.find(params[:id])
  end

  def find_account
    @account = Account.find(params[:account_id])
  end
end