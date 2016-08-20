class ProductsController < ApplicationController
  before_action :find_account, only: [:new, :create]
  before_action :find_product, only: [:show, :edit, :update, :destroy, :checked]

  def index
    @products = Product.all
  end

  def new
    @product = @account.products.new
    protection
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
    protection
  end

  def update
    if @product.update(product_params)
      redirect_to @product.account
    else
      render :edit
    end
  end

  def destroy
    protection
    @product.destroy
    redirect_to @product.account
  end

  def checked
    @product.update_attributes(updated_at: Time.now, prev_updated_at: Time.now)
    redirect_to :back
  end

  private

  def find_account
    @account = Account.find(params[:account_id])
  end

  def find_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description)
  end

  def protection
    redirect_to root_path if @product.account.locked? && !current_user.admin?
  end

end