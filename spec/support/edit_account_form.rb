class EditAccountForm
  include Capybara::DSL

  def visit_page(page_path)
    visit page_path

    self
  end

  def fill_in_with(options = {})
    fill_in 'account[name]',            with: options[:name]
    fill_in 'account[birthday_on]',     with: options[:birthday_on]
    fill_in 'account[goal]',            with: options[:goal]
    fill_in 'account[budget]',          with: options[:budget]
    fill_in 'account[deadline_on]',     with: options[:deadline_on]
    fill_in 'account[payment_details]', with: options[:payment_details]
    fill_in 'account[phone_number]',    with: options[:phone_number]
    fill_in 'account[contact_person]',  with: options[:contact_person]
    fill_in 'account[backers]',         with: options[:backers]
    fill_in 'account[collected]',       with: options[:collected]
    fill_in 'account[overview]',        with: options[:overview]
  
    self
  end

  def submit
    click_on I18n.t('.save')

    self
  end

  def cancel
    click_on I18n.t('.cancel')

    self
  end
end
