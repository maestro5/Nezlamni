class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :show]
  before_action :find_product, only: [:new, :create]
  before_action :find_order, only: :delivered
  before_action :visible_account_product!, only: [:new, :create]
  before_action :admin_or_owner!, only: :delivered

  def index
    @orders = current_user.admin? ? Order.all.order(created_at: :desc) : current_user.account.orders.order(created_at: :desc)
  end

  def new
    @order = @product.orders.new
  end

  def create
    @order = @product.orders.build(order_params)
    @order.account = @product.account
    if @order.save
      redirect_to @order
    else
      redirect_to :back
    end
  end

  def show
  end

  def delivered
    @order.delivery!
    redirect_to :back
  end

  private

    def find_product
      @product = Product.find(params[:product_id])
    end

    def find_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:contribution, :recipient, :phone, :email, :address)
    end

    def visible_account_product!
      return if @product.account.visible? && @product.visible?
      redirect_to root_path
    end

    def admin_or_owner!
      return if current_user.account == @order.account && !@order.account.locked?
      return if current_user.admin?
      redirect_to root_path
    end
end