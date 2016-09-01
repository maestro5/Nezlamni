class ImagesController < ApplicationController
  before_action :find_imageable, except: [:destroy]

  def index
    @images = @imageable.images
  end

  def new
    @image = @imageable.images.new
  end

  def create
    @image = @imageable.images.build(image_params)
    if @image.save
      redirect_to :back
    else
      redirect_to :back
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to :back
  end

  def set_avatar
    @image = Image.find(params[:id])
    @imageable.update_attribute(:avatar_url, @image.image_url)

    redirect_to edit_account_path(@imageable) if @imageable.is_a? Account
    redirect_to edit_product_path(@imageable) if @imageable.is_a? Product
  end

  private

  def find_imageable
    @imageable = if params.include? 'account_id'
      Account.find(params[:account_id])
    else
      Product.find(params[:product_id])
    end
  end

  def image_params
    params.require(:image).permit(:image)
  end
end