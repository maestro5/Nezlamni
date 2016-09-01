class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :show]
  before_action :find_product, only: [:new, :create]
  before_action :find_order, only: [:show, :delivered]

  def index
    @orders = Order.all
  end

  def new
    @order = @product.orders.new
  end

  def create
    @order = @product.orders.build(order_params)
    if @order.save
      redirect_to @order
    else
      redirect_to :back
    end
  end

  def show
  end

  def delivered
    account = @order.product.account
    last_delivered = @order.delivered

    @order.toggle!(:delivered)

    if !last_delivered && @order.delivered?
      account.update_attribute(:backers, account.backers + 1)
    elsif last_delivered && !@order.delivered?
      account.update_attribute(:backers, account.backers - 1)
    end

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
    params.require(:order).permit(:address, :recipient, :phone, :email)
  end
end