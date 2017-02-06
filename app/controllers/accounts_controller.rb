class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :find_account, except: %i(index new create)
  before_action :admin!, only: %i(destroy checked visible locked)
  before_action :admin_or_owner!, only: %i(edit update)
  before_action :visible_account!, only: :show

  def index
    @accounts = Account.order(deadline_on: :asc)
    @accounts = @accounts.where(id: current_user.accounts) unless current_user.admin?
    @accounts = @accounts.page(params[:page]).per(10)
  end

  def show
    @products = @account.products.order(contribution: :asc)
    @articles = @account.articles.order(created_at: :desc)
    @comments = @account.comments

    if current_user.nil? # visitor
      @products = @products.where(visible: true)
      @articles = @articles.where(visible: true)
    end
  end

  def new
    @account = current_user.accounts.build
  end

  def create
    @account = current_user.accounts.build(account_params)
    if @account.save
      flash[:success] = 'Сторінка збору успішно створена і відправлена на модерацію адміністратору.'
      redirect_to @account
    else
      render 'new'
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
    @account.destroy
    redirect_to accounts_path
  end

  def checked
    @account.update_attribute(:was_changed, false)
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
    params
      .require(:account)
      .permit(
        :name, :birthday_on, :goal, :budget, :backers, :collected, :deadline_on,
        :phone_number, :contact_person, :payment_details, :overview
      )
  end # account_params

  def find_account
    @account = Account.find(params[:id])
  end

  def visible_account!
    return if @account.visible?
    return if !current_user.nil? &&
      (current_user.accounts.include?(@account) || current_user.admin?)
    redirect_to root_path
  end

  def admin_or_owner!
    return if current_user.admin?
    return if current_user.accounts.include?(@account) && !@account.locked?
    redirect_to root_path
  end
end # AccountsController
