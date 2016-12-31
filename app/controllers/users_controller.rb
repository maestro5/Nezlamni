class UsersController < ApplicationController
  before_action :admin!

  def index
    @users = 
      User
        .includes(:accounts)
        .order(created_at: :desc)
        .page(params[:page])
        .per(9)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
end
