module ApplicationHelper
  def date_format(date)
    return if date.nil?
    date.strftime('%d.%m.%Y')
  end

  def date_time_format(date)
    return if date.nil?
    date.localtime.strftime('%d.%m.%Y %H:%M:%S')
  end

  def accounts_tr_class(account)
    return if account.nil?
    if account.collected > 0 && account.collected >= account.budget # compleated
      'success'
    elsif account.created_at == account.updated_at # new
      'warning'
    elsif account.was_changed? # changed
      'info'
    elsif account.locked? || !account.visible?
      'danger'
    end
  end

  def products_tr_class(product)
    return if product.nil?

    if product.created_at == product.updated_at # new
      'warning'
    elsif product.was_changed? # changed
      'info'
    elsif !product.visible?
      'danger'
    end
  end

  # def owner?(account)
  #   return true if current_user.admin?
  #   current_user.accounts.include? account
  # end

  def owner_profile?(user)
    return unless current_user
    current_user.admin? || current_user == user
  end

  def avatar(obj)
    obj.avatar_url || obj.try(:remote_avatar) || 'empty_avatar.jpg'
  end

  def avatar_mini(obj)
    obj.avatar_url(:mini) || obj.try(:remote_avatar) || 'empty_avatar_mini.jpg'
  end
end
