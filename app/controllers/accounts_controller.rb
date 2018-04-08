class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action :verify_authorization!, only: %i(edit update destroy)
  # before_action :find_account, except: %i(index update)
  # before_action :admin!, only: %i(destroy checked visible locked)
  # before_action :admin_or_owner!, only: %i(edit update)
  # before_action :visible_account!, only: :show

  helper_method :account_decorator

  ACCOUNTS_ON_THE_PAGE = 9

  def index
    @accounts = Account.order(deadline_on: :asc)
    @accounts = @accounts.where(id: current_user.accounts) unless current_user.admin?
    @accounts = @accounts.page(params[:page]).per(ACCOUNTS_ON_THE_PAGE)
  end

  def show
    @products = account.products.order(contribution: :asc)
    @articles = account.articles.order(created_at: :desc)
    @comments = account.comments

    if current_user.nil? # visitor
      @products = @products.where(visible: true)
      @articles = @articles.where(visible: true)
    end
  end

  def new
    @account = current_user.accounts.create
    redirect_to edit_account_path(@account)
  end

  def edit
  end

  def update
    # use call for the service object

    # use here respond_with
    if updater.update
      flash[:success] = 'Сторінка збору успішно створена і відправлена на модерацію адміністратору.'
      redirect_to updater.account
    else
      render json: updater.account.errors.as_json, status: 403
    end
  end

  def destroy
    if account.update_attribute(:deleted, true)
      flash[:success] = I18n.t('.flash.account.deleted') unless params[:cancel].present?
    end

    redirect_to accounts_path
  end

  # def checked
  #   @account.update_attribute(:was_changed, false)
  #   redirect_to accounts_path
  # end

  # def visible
  #   @account.toggle!(:visible)
  #   redirect_to accounts_path
  # end

  # def locked
  #   @account.toggle!(:locked)
  #   redirect_to accounts_path
  # end

  # alias_method :new, :edit

  private

  def authorized?
    account.authorized?(current_user)
  end

  def updater
    @updater ||= AccountUpdaterService.new(account: account, account_form: account_form)
  end

  def account_form
    @account_form ||= AccountForm.new(params)
  end

  def account
    @account ||= Account.find(params[:id]) if params[:id]
  end

  def account_decorator
    @account_decorator ||= AccountDecorator.new(account)
  end

  def visible_account!
    return if account.visible?
    return if !current_user.nil? &&
      (current_user.accounts.include?(account) || current_user.admin?)
    redirect_to root_path
  end

  def admin_or_owner!
    return if current_user.admin?
    return if current_user.accounts.include?(account) && !account.locked?
    redirect_to root_path
  end
end # AccountsController
