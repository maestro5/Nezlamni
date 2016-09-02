class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @accounts = Account.all
  end

  def products
    protection
    @products = Product.all
  end

  def protection
    redirect_to root_path unless current_user.admin?
  end
end
