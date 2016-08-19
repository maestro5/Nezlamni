module ApplicationHelper
  def date_format(date)
    return if date.nil?
    date.strftime('%d.%m.%Y')
  end

  def accounts_tr_class(account)
    return if account.nil?
    if account.collected > 0 && account.collected >= account.budget
      'success'
    elsif account.prev_updated_at == '0001-01-01'
      'warning'
    elsif account.updated_at > account.prev_updated_at
      'info'
    elsif account.locked? || !account.visible?
      'danger'
    end
  end

  def products_tr_class(product)
    return if product.nil?

    if product.prev_updated_at == '0001-01-01'
      'warning'
    elsif product.updated_at > product.prev_updated_at
      'info'
    elsif !product.visible?
      'danger'
    end
  end
end
