class AccountsController < ApplicationController
  def inex
  end

  def show
    @account = Account.find(params[:id])
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])

    if @account.update(account_params)
      redirect_to @account
    else
      render 'edit'
    end
  end

  def destroy
  end

  private

    def account_params
      params.require(:account).permit(:name, :birthday, :goal, :budget, :backers, :collected, :deadline, :payment_details, :overview)
    end


end