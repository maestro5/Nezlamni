class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :show]
  before_action :find_product, only: [:new, :create]
  before_action :find_order, only: [:show, :delivered]

  def index
    @orders = current_user.admin? ? Order.all : current_user.account.orders
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
    account = @order.account
    product = @order.product
    last_delivered = @order.delivered

    @order.toggle!(:delivered)

    if !last_delivered && @order.delivered?
      account.update_attributes(
        backers: account.backers + 1,
        collected: account.collected + @order.contribution
      )
      product.update_attribute(:backers, product.backers + 1)
    elsif last_delivered && !@order.delivered?
      account.update_attributes(
        backers: account.backers - 1,
        collected: account.collected - @order.contribution
      )
      product.update_attribute(:backers, product.backers - 1)
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
    params.require(:order).permit(:contribution, :recipient, :phone, :email, :address)
  end
end