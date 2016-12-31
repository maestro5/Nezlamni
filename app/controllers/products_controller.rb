class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i(show index)
  before_action :find_account, only: %i(new create index)
  before_action :find_product, except: %i(index new create)
  before_action :admin!, only: %i(checked visible)
  before_action :admin_or_owner!, only: %i(create edit update destroy)
  before_action :visible_account_product!, only: :index

  def index
    @products = @account.products.order(contribution: :asc)
    @products = @products.where(visible: true) if current_user.nil? #visitor
  end

  def new
    @product = @account.products.new
    admin_or_owner!
  end

  def create
    @product = @account.products.build(product_params)
    if @product.save
      redirect_to @account
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product.account
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to :back
  end

  def checked
    @product.update_attribute(:was_changed, false)
    redirect_to :back
  end

  def visible
    @product.toggle!(:visible)
    redirect_to products_path
  end

  private

    def find_account
      @account = Account.find(params[:account_id])
    end

    def find_product
      @product = Product.find(params[:id])
    end

    def product_params
      params
        .require(:product)
        .permit(:contribution, :title, :description, :backers, :remainder)
    end

    def visible_account_product!
      return if @account.visible?
      return if !current_user.nil? && 
        (current_user.accounts.include?(@account) || current_user.admin?)
      redirect_to root_path
    end

    def admin_or_owner!
      obj = @account || @product.account
      return if current_user.accounts.include?(obj) && !obj.locked?
      return if current_user.admin?
      redirect_to root_path
    end
end
