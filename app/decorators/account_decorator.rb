class AccountDecorator < SimpleDelegator
  def age
    return '' unless birthday_on.is_a?(Date)
    now = Time.now.utc.to_date

    now.year - birthday_on.year - (birthday_on.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def title
    return '' if name.blank?

    msg = name.clone
    msg << ", #{age}"  unless age.blank?
    msg << ". #{goal}" unless goal.blank?

    msg
  end

  def collected_percent
    return 0.0 unless budget.is_a?(Numeric) && collected.is_a?(Numeric) &&
                      budget > 0            && collected > 0

    ((collected / budget) * 100).round(2)
  end

end
