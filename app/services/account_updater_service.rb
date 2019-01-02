class AccountUpdaterService
  attr_reader :account, :account_form
  delegate :errors, to: :account

  def update
    valid? && update_account && create_default_product
  end

  private

  def initialize(account:, account_form:)
    @account      = account
    @account_form = account_form
  end

  def valid?
    return true if account_form.valid?

    account_form.errors.messages.each { |error, message| account.errors[error] = message }

    false
  end

  def update_account
    account.update(account_form.attributes)
  end

  def create_default_product
    return true if account.products.any?(&:default)

    product = account.products.create(Product::DEFAULT_ATTRIBUTES)

    product.persisted?
  end
end
