class AccountsController < ApplicationController
  before_action :find_account, only: [:show, :edit, :update, :checked, :locked]

  def index
    @accounts = Account.all
  end

  def show
  end

  def edit
    protection
  end

  def update
    if @account.update(account_params)
      redirect_to @account
    else
      render 'edit'
    end
  end

  def checked
    @account.update_attributes(updated_at: Time.now, prev_updated_at: Time.now)
    redirect_to accounts_path
  end

  def locked
    @account.toggle!(:locked)
    redirect_to accounts_path
  end

  def destroy
  end

  private

    def account_params
      params.require(:account).permit(:name, :birthday_on, :goal, :budget, :backers, :collected, :deadline_on, :payment_details, :overview)
    end

    def find_account
      @account = Account.find(params[:id])
    end

    def protection
      redirect_to root_path if @account.locked? && !current_user.admin?
    end
end
