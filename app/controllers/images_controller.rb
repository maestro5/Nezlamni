class ImagesController < ApplicationController
  # before_action :find_image, only: %i(destroy set_avatar)
  # before_action :admin_or_owner!
  respond_to :json

  def index
    @images = imageable.images
  end

  def new
    @image = imageable.images.new
  end

  def create
    @image = imageable.images.create(image_params)   
    respond_with @image
  end

  def destroy
    image.destroy
    respond_with image
    # redirect_to :back
  end

  def set_avatar
    imageable.update_attribute(:avatar_url, image.image_url)
    redirect_to edit_account_path(imageable) if imageable.is_a? Account
    redirect_to edit_product_path(imageable) if imageable.is_a? Product
  end

private
  def imageable
    return @imageable ||= Account.find(params[:account_id]) if params.include?('account_id')
    @imageable ||= Product.find(params[:product_id])
  end

  def image
    @image ||= Image.find(params[:id])
  end

  def image_params
    params.require(:imageable).permit(:image)
  end

  # def admin_or_owner!
  #   @imageable ||= @image.nil? ? nil : @image.imageable
  #   obj = @imageable.is_a?(Account) ? @imageable : @imageable.account

  #   return if current_user.accounts.include?(obj) && !obj.locked?
  #   return if current_user.admin?
  #   redirect_to root_path
  # end
end
