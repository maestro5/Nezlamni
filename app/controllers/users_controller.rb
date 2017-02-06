class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :set_user, only: %i(destroy show edit update)
  before_action :admin!, only: %i(index destroy)
  before_action :admin_or_owner!, only: %i(edit update)

  def index
    @users = 
      User
        .includes(:accounts)
        .order(created_at: :desc)
        .page(params[:page])
        .per(9)
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :avatar)
  end

  def admin_or_owner!
    return if current_user.admin?
    return if @user == current_user
    redirect_to root_path
  end
end
