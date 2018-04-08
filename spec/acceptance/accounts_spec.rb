require_relative '../acceptance_helper'
require_relative '../support/edit_account_form'

shared_examples_for 'edit account' do
  let!(:account) { create(:account, user: user) }
  let(:edit_account_form) { EditAccountForm.new }

  let(:name) { 'John Galt' }
  let(:goal) { 'My test goal' }
  let(:options) { attributes_for(:account, name: name, goal: goal) }
  let(:max_age) { AccountForm::MAX_AGE }
  let(:min_deadline_period) { AccountForm::MIN_DEADLINE_PERIOD }
  let(:date_today) { Date.today }
  let(:date_tomorrow) { Date.tomorrow }
  let(:date_max_years_ago) { max_age.years.ago }
  let(:date_yesterday) { Date.yesterday }
  let(:date_a_day_before_deadline) { date_today.days_since(min_deadline_period - 1) }
  let(:string) { 'tXT' }
  let(:number_less_than_zero) { -3 }
  let(:number_zero) { 0 }

  let(:error_blank) { I18n.t('.errors.messages.blank') }
  let(:error_not_a_number) { I18n.t('.errors.messages.not_a_number') }
  let(:error_greater_than_zero) { I18n.t('errors.messages.greater_than', count: 0) }
  let(:error_birthday_in_the_past) { I18n.t('.errors.account_form.birthday_on_in_the_past', count: max_age) }
  let(:error_deadline_in_the_future) { I18n.t('.errors.account_form.deadline_on_in_the_future', count: min_deadline_period) }
  let(:error_not_a_date) { I18n.t('.errors.messages.not_a_date') }

  before do
    edit_account_form
      .visit_page(edit_account_path(subject))
      .fill_in_with(options)
      .submit
  end

  subject { Account.last }

  shared_examples_for 'with invalid params' do
    scenario "it's returns 403 status" do
      expect(status_code).to eq 403
    end

    # scenario "it's renders account edit page" do
    #   expect(current_path).to eq edit_account_path(account)
    # end

    scenario "it doesn't save in db" do
      key = options.keys.first

      expect(subject.public_send(key)).not_to eq options[key]
    end

    scenario "it's shows errors" do
      expected_errors.each do |e|
        expect(page).to have_content(e[:error], count: e[:count] || 1)
      end
    end
  end

  context "when invalid params" do
    context "when params are blank" do
      let(:options) { { name: '' } }
      let(:expected_errors) do
        [ { error: error_blank, count: 5}, { error: error_not_a_number } ]
      end

      it_behaves_like 'with invalid params'
    end

    context "when budget is not a number" do
      let(:options) { { budget: string } }
      let(:expected_errors) { [ { error: error_not_a_number } ] }

      it_behaves_like 'with invalid params'
    end

    context "when budget is 0" do
      let(:options) { { budget: number_zero } }
      let(:expected_errors) { [ { error: error_greater_than_zero } ] }

      it_behaves_like 'with invalid params'
    end

    context "when budget is less than 0" do
      let(:options) { { budget: number_less_than_zero } }
      let(:expected_errors) { [ { error: error_greater_than_zero } ] }

      it_behaves_like 'with invalid params'
    end

    context "when birthday is in the future" do
      let(:options) { { birthday_on: date_tomorrow } }
      let(:expected_errors) { [ { error: error_birthday_in_the_past } ] }

      it_behaves_like 'with invalid params'
    end

    context "when birthday is today" do
      let(:options) { { birthday_on: date_today } }
      let(:expected_errors) { [ { error: error_birthday_in_the_past } ] }

      it_behaves_like 'with invalid params'
    end

    context "when birthday is less than max age" do
      let(:options) { { birthday_on: date_max_years_ago } }
      let(:expected_errors) { [ { error: error_birthday_in_the_past } ] }

      it_behaves_like 'with invalid params'
    end

    context "when birthday is not a date" do
      let(:options) { { birthday_on: string } }
      let(:expected_errors) { [ { error: error_not_a_date } ] }

      it_behaves_like 'with invalid params'
    end

    context "when deadline is in the past" do
      let(:options) { { deadline_on: date_yesterday } }
      let(:expected_errors) { [ { error: error_deadline_in_the_future } ] }

      it_behaves_like 'with invalid params'
    end

    context "when deadline is less than min deadline period (days)" do
      let(:options) { { deadline_on: date_a_day_before_deadline } }
      let(:expected_errors) { [ { error: error_deadline_in_the_future } ] }

      it_behaves_like 'with invalid params'
    end

    context "when deadline is not a date" do
      let(:options) { { deadline_on: string } }
      let(:expected_errors) { [ { error: error_not_a_date } ] }

      it_behaves_like 'with invalid params'
    end
  end

  context "when valid params" do
    scenario "it's saves account in db" do
      subject.reload

      expect(subject.name).to            eq options[:name]
      expect(subject.birthday_on).to     eq options[:birthday_on]
      expect(subject.goal).to            eq options[:goal]
      expect(subject.budget).to          eq options[:budget]
      expect(subject.backers).to         eq options[:backers]
      expect(subject.collected).to       eq options[:collected]
      expect(subject.deadline_on).to     eq options[:deadline_on]
      expect(subject.payment_details).to eq options[:payment_details]
      expect(subject.overview).to        eq options[:overview]
      expect(subject.avatar_url).to      eq options[:avatar_url]
      expect(subject.phone_number).to    eq options[:phone_number]
      expect(subject.contact_person).to  eq options[:contact_person]
    end

    scenario "it's redirects to account show page" do
      expect(current_path).to eq account_path(subject)
    end

    scenario "it doesn't change default products count" do
      expect(subject.products.count).to eq 1
    end

    context "when the name needs to be improved" do
      let(:name) { '  bIlL    gaTes   ' }
      let(:improved_name) { 'Bill Gates' }

      scenario "it's improves the name" do
        expect(subject.reload.name).to eq improved_name
      end
    end

    context "when the goal needs to be improved" do
      let(:goal) { '   mY  nEw uPDatEd     GOaL   ' }
      let(:improved_goal) { 'My new updated goal' }

      scenario "it's improves the name" do
        expect(subject.reload.goal).to eq improved_goal
      end
    end
  end
end

shared_examples_for 'destroy account' do |option = :contains_flash_message|
  let(:flash_success_msg) { I18n.t('.flash.account.deleted') }

  before { destroy_action }

  scenario "doesn't delete in db" do
    expect(account.destroyed?).to be false
  end

  scenario "marks account as deleted" do
    expect(account.reload.deleted).to be true
  end

  scenario "redirect to accounts page" do
    expect(current_path).to eq accounts_path
  end

  scenario "page contains deleting success message", js: true do
    if option == :contains_flash_message
      expect(page).to have_content flash_success_msg
    else
      expect(page).not_to have_content flash_success_msg
    end
  end

  scenario "delete all association objects"
end

shared_examples_for "doesn't contain owner actions" do
  let(:edit_button) { I18n.t('accounts.show.edit') }
  let(:delete_buttn) { I18n.t('accounts.show.delete') }
  let(:owner_actions) { [edit_button, delete_buttn] }

  scenario "it doesn't contain owner's actions" do
    owner_actions.each { |owner_action| expect(page).not_to have_content owner_action }
  end
end

shared_examples_for 'access denied' do
  before { visit path }

  let(:error_access_denied) { I18n.t('flash.access_denied') }

  scenario 'it redirects to home page' do
    expect(current_path).to eq root_path
  end

  scenario 'it shows access denied message', js: true do
    expect(page).to have_content error_access_denied
  end
end


# =====================================
# role:   user
# action: create
# =====================================
feature 'User creates an account', %q{
  As a user
  I want to be able to create an account
} do

  let(:user) { create(:user) }
  let(:new_account_form) { EditAccountForm.new }

  before { sign_in user }

  subject { Account.last }

  context 'when initial a new, default account' do
    before do |spec|
      new_account_form.visit_page(new_account_path) unless spec.metadata[:skip_before]
    end

    scenario "it's belongs to current user" do
      expect(subject.user).to eq user
    end

    scenario "it's has default-empty values" do
      expect(subject.name).to            be_blank
      expect(subject.birthday_on).to     be_nil
      expect(subject.goal).to            be_blank
      expect(subject.budget).to          eq 0.0
      expect(subject.backers).to         eq 0
      expect(subject.collected).to       eq 0.0
      expect(subject.deadline_on).to     be_nil
      expect(subject.payment_details).to be_blank
      expect(subject.overview).to        be_blank
      expect(subject.avatar_url).to      be_nil
      expect(subject.phone_number).to    be_nil
      expect(subject.contact_person).to  be_nil
    end

    scenario "it's has default states" do
      expect(subject.visible).to     be false
      expect(subject.locked).to      be false
      expect(subject.was_changed).to be false
    end

    scenario "it's has empty associations" do
      expect(subject.images).to   be_empty
      expect(subject.products).to be_empty
      expect(subject.orders).to   be_empty
      expect(subject.articles).to be_empty
      expect(subject.comments).to be_empty
    end

    scenario "it's redirects to account edit page" do
      expect(current_path).to eq edit_account_path(subject)
    end

    scenario "it's creates new account in db", skip_before: true do
      expect{ new_account_form.visit_page(new_account_path) }.to change(Account, :count).by(+1)
    end

    scenario "it's doesn't creates a default product", skip_before: true do
      expect{ new_account_form.visit_page(new_account_path) }.not_to change(Product, :count)
    end

    context "when cancels the creating" do
      let(:destroy_action) { new_account_form.cancel }
      let(:account) { Account.last }

      scenario "it's redirects on accounts page" do
        new_account_form.cancel

        expect(current_path).to eq accounts_path
      end

      it_behaves_like 'destroy account', :not_contains_flash_message
    end
  end

  context "when creates an account" do
    it_behaves_like 'edit account'
  end
end

# =====================================
# role:   user
# action: update
# =====================================
feature 'User edit an account', %q{
  As a user
  I want to be able to edit my own account
} do

  let(:user) { create(:user) }

  before { sign_in user }

  it_behaves_like 'edit account'

  context 'when edits not own account' do
    let(:account) { create(:account, user: create(:user)) }

    context 'on account page' do
      before { visit account_path(account) }

      it_behaves_like "doesn't contain owner actions"
    end

    context 'when tries to get edit page' do
      let(:path) { edit_account_path(account) }

      it_behaves_like 'access denied'
    end
  end

  scenario 'on accounts page'
end

# =====================================
# role:   user
# action: destroy
# =====================================
feature 'User destroy an account', %q{
  As a user
  I want to be able to destroy my own account
} do

  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }
  let(:delete_btn_text) { I18n.t('accounts.owner_buttons.delete') }
  let(:destroy_action) { delete_btn.click }

  before do
    sign_in user
    visit path
  end

  context "on the account page" do
    let(:path) { account_path(account) }
    let(:delete_btn) { find('a', text: delete_btn_text) }

    it_behaves_like 'destroy account'
  end

  context "on accounts page" do
    let(:path) { accounts_path }
    let(:delete_btn) { all('.account').last.find('a', text: delete_btn_text) }

    it_behaves_like 'destroy account'
  end

  context 'when deletes not own account' do
    let(:not_owner_account) { create(:account, user: create(:user)) }
    let(:path) { account_path(not_owner_account) }

    it_behaves_like "doesn't contain owner actions"
  end
end








# =====================================
# role: admin
# =====================================
feature 'Admin creates an account', %q{
  As an admin
  I want to be able to create an account
} do

  let(:user_admin) { create(:user_admin) }

  xscenario 'when admin creates an account' do
    # sign_in user_admin
    # click_on 'Зібрати кошти'

    # fill_in 'account[name]', with: 'Bob Stark'
    # fill_in 'account[goal]', with: 'Treatment'
    # fill_in 'account[budget]', with: 37500
    # fill_in 'account[deadline_on]', with: Time.now + 2.month
    # fill_in 'account[birthday_on]', with: '21/05/2007'
    # fill_in 'account[payment_details]', with: 'Delaware National Bank, account: 8190419'

    # expect{click_on 'Зберегти'}.to change(Account, :count).by(+1)
  end # when admin creates an account
end # Admin creates an account






# ============================================================
# move to permissions test
# ============================================================
# =====================================
# role: visitor
# =====================================
feature 'Visitor creates an account', %q{
  As a visitor
  I can't create an account
} do

  let(:rais_funds_button) { I18n.t('shared.navbar.raise_funds') }
  let(:support_person_button) { I18n.t('accounts.show.support_person') }
  let(:visitor_actions) { [support_person_button] }
  # let(:admin_actions) { [] }
  let(:account) { create(:account) }

  scenario 'when visitor creates an account' do
    visit root_path
    click_on rais_funds_button

    expect(current_path).to eq new_user_session_path
  end

  scenario 'when visitor edits an account' do
    visit edit_account_path(account)

    expect(current_path).to eq new_user_session_path
  end

  scenario 'when visitor visits accounts page' do
    visit accounts_path

    expect(current_path).to eq new_user_session_path
  end

  context 'when visitor visits account page' do
    before { visit account_path(account) }

    scenario "it's account show page" do
      expect(current_path).to eq account_path(account)
    end

    it_behaves_like "doesn't contain owner actions"

    scenario "it contains available actions" do
      visitor_actions.each { |visitor_action| expect(page).to have_content visitor_action }
    end

    scenario "it contains account"
    scenario "it contains products"
    scenario "it contains articles"
    scenario "it contains comments"
  end
end # Guest creates an account

# ============================================================
# pages tests
# ============================================================
# scenario "account show page contains accont data" do
#   within "#account_title" do
#     expect(page).to have_content account_title
#   end

#   within "#backers" do
#     expect(page).to have_content subject.backers
#   end
#   within "#collected" do
#     expect(page).to have_content subject.collected
#     expect(page).to have_content subject.budget
#   end
#   within "#deadline" do
#     # expect(page).to have_content subject.deadline_on
#   end
#   within "#contacts" do
#     expect(page).to have_content subject.phone_number
#     expect(page).to have_content subject.contact_person
#   end

#   within "#overview" do
#     expect(page).to have_content subject.overview
#   end

#   expect(page).not_to have_content subject.payment_details

#   # within "#products" do
#   #   # expect(page).to have_content subject.products.first
#   # end
# end


# ============================================================
# notifications
# ============================================================
# xscenario "it's changes account states" do
#   # expect(subject.was_changed).to be true
# end


# ============================================================
# images
# feature 'User sets an avatar for own account', %q{
#   As a user
#   I want to be able to set an avatar for my account
# } do

#   let(:user) { create(:user) }
#   xscenario "sets account's avatar" do

#   end
# end
# ============================================================


