class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :find_account, except: [:index]
  before_action :admin!, only: [:index, :destroy, :checked, :visible, :locked]
  before_action :admin_or_owner!, only: [:edit, :update]
  before_action :visible_account!, only: :show

  def index
    @accounts = Account.all.order(deadline_on: :asc).page(params[:page]).per(10)
  end

  def show
    if current_user.nil? # visitor
      @products = @account.products.where(visible: true).order(contribution: :asc)
      @articles = @account.articles.where(visible: true).order(created_at: :desc)
    else
      @products = @account.products.order(contribution: :asc)
      @articles = @account.articles.order(created_at: :desc)
    end
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

  def destroy
    @account.user.destroy
    redirect_to accounts_path
  end

  def checked
    @account.update_attributes(updated_at: Time.now, prev_updated_at: Time.now)
    redirect_to accounts_path
  end

  def visible
    @account.toggle!(:visible)
    redirect_to accounts_path
  end

  def locked
    @account.toggle!(:locked)
    redirect_to accounts_path
  end

  private

    def account_params
      params.require(:account).permit(
        :name,
        :birthday_on,
        :goal,
        :budget,
        :backers,
        :collected,
        :deadline_on,
        :phone_number,
        :contact_person,
        :payment_details,
        :overview
      )
    end # account_params

    def find_account
      @account = Account.find(params[:id])
    end

    def visible_account!
      return if @account.visible?
      return if !current_user.nil? &&
        (current_user.account.id == @account.id || current_user.admin?)
      redirect_to root_path
    end

    def admin_or_owner!
      return if current_user.account.id == @account.id && !@account.locked?
      return if current_user.admin?
      redirect_to root_path
    end
end # AccountsController
