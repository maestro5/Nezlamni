class AccountsController < ApplicationController
  before_action :find_account, only: [:show, :edit, :update, :checked]

  def index
    @accounts = Account.all
  end

  def show
  end

  def edit
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

  def destroy
  end

  private

    def account_params
      params.require(:account).permit(:name, :birthday_on, :goal, :budget, :backers, :collected, :deadline_on, :payment_details, :overview)
    end

    def find_account
      @account = Account.find(params[:id])
    end

end
