require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor available comments', %q{
  As a visitor
  I am available to comments
} do

  let(:user)          { create :user }
  let(:account)       { create :account, user: user, visible: true }
  let!(:user_comment) { create :comment, user: user, account: account }

  scenario 'when visitor browses account comments' do
    visit account_path(account)

    expect(current_path).to eq account_path(account)
    expect(page).to have_content user_comment.body
    expect(page).to have_link user.name
    expect(page).to have_css('a[href=\'' + user_path(user) + '\']')
    expect(page).not_to have_css('a[href=\'' + account_comment_path(account, user_comment) + '\']') # delete
    expect(page).not_to have_css('#new_comment')
  end

end # Visitor available comments

# =====================================
# role: user
# =====================================
feature 'User available comments', %q{
  As a user
  I am available to comment
} do

  let(:user)       { create :user }
  let(:user_guest) { create :user }
  let(:user_admin) { create :user_admin }
  let(:account)    { create :account, user: user, visible: true }
  let!(:comment_guest) { create :comment, user: user_guest, account: account }
  let!(:comment_account_owner) { create :comment, user: user, account: account }
  let!(:comment_admin) { create :comment, user: user_admin, account: account }

  scenario 'account owner and comment owner available to comments' do
    [user, user_guest].each do |u|
      sign_in u
      visit account_path(account)

      expect(current_path).to eq account_path(account)
      expect(page).to have_content comment_guest.body
      expect(page).to have_content comment_account_owner.body
      expect(page).to have_content comment_admin.body
      
      expect(page).to have_link user_guest.name
      expect(page).to have_link user.name
      expect(page).to have_link user_admin.name    

      expect(page).to have_css('a[href=\'' + user_path(user_guest) + '\']')
      expect(page).to have_css('a[href=\'' + user_path(user) + '\']')
      expect(page).to have_css('a[href=\'' + user_path(user_admin) + '\']')
      expect(page).to have_css('#new_comment')

      click_on 'Вийти'
    end
  end

  scenario 'when account owner and user (guest) create a new comment', js: true do
    [user, user_guest].each do |u|
      sign_in u
      visit account_path(account)
      click_on 'Коментарі'
      fill_in 'comment[body]', with: "#{u.name} new test comment"

      click_on 'Додати коментар'
      expect(current_path).to eq account_path(account)
      expect(page).to have_content "#{u.name} new test comment"

      click_on 'Вийти'
    end
  end

  context 'comment owner (guest)' do
    before do
      sign_in user_guest
      visit account_path(account)
      click_on 'Коментарі'
    end

    scenario 'able to edit only your own comment' do
      expect(page).to have_css("#comment-#{comment_guest.id}-edit")
      expect(page).not_to have_css("#comment-#{comment_account_owner.id}-edit")
      expect(page).not_to have_css("#comment-#{comment_admin.id}-edit")
    end

    scenario 'when edit your own comment with invalid data', js: true do
      within "#comment_#{comment_guest.id}" do
        find('.comment-edit-link').click
      end

      within "#comment-#{comment_guest.id}-edit" do
        fill_in 'comment[body]', with: ''
        click_on 'Зберегти'
        expect(page).to have_content 'Body can\'t be blank'
      end
      expect(comment_guest.reload.body).not_to be_empty
    end

    scenario 'when edit your own comment with valid data', js: true do
      within "#comment_#{comment_guest.id}" do
        find('.comment-edit-link').click
      end

      within "#comment-#{comment_guest.id}-edit" do
        fill_in 'comment[body]', with: 'Comment owner (guest) edited comment'
        click_on 'Зберегти'
      end

      within "#comment_#{comment_guest.id}" do
        expect(page).to have_content 'Comment owner (guest) edited comment'
      end
      expect(comment_guest.reload.body).to eq 'Comment owner (guest) edited comment'
    end

    scenario 'able to delete only your own comment' do
      expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_guest) + '\']')             # delete
      expect(page).not_to have_css('a[href=\'' + account_comment_path(account, comment_account_owner) + '\']') # delete
      expect(page).not_to have_css('a[href=\'' + account_comment_path(account, comment_admin) + '\']')         # delete
    end

    scenario 'when delete own comment', js: true do
      within "#comment_#{comment_guest.id}" do
        find('.comment-delete-link').click
      end
      page.driver.browser.switch_to.alert.accept
      expect(page).not_to have_content "#{user_guest.name} test comment"
    end
  end # comment owner (guest)

  context 'account owner' do
    before do
      sign_in user
      visit account_path(account)
      click_on 'Коментарі'
    end

    scenario 'able to edit only your own comment' do
      expect(page).to have_css("#comment-#{comment_account_owner.id}-edit")
      expect(page).not_to have_css("#comment-#{comment_guest.id}-edit")
      expect(page).not_to have_css("#comment-#{comment_admin.id}-edit")
    end

    scenario 'when edit your own comment with invalid data', js: true do
      within "#comment_#{comment_account_owner.id}" do
        find('.comment-edit-link').click
      end

      within "#comment-#{comment_account_owner.id}-edit" do
        fill_in 'comment[body]', with: ''
        click_on 'Зберегти'
        expect(page).to have_content 'Body can\'t be blank'
      end
      expect(comment_account_owner.reload.body).not_to be_empty
    end

    scenario 'when edit your own comment with valid data', js: true do
      within "#comment_#{comment_account_owner.id}" do
        find('.comment-edit-link').click
      end

      within "#comment-#{comment_account_owner.id}-edit" do
        fill_in 'comment[body]', with: 'Account owner edited comment'
        click_on 'Зберегти'
      end

      within "#comment_#{comment_account_owner.id}" do
        expect(page).to have_content 'Account owner edited comment'
      end
      expect(comment_account_owner.reload.body).to eq 'Account owner edited comment'
    end

    scenario 'able to delete any comment' do
      expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_guest) + '\']')         # delete
      expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_account_owner) + '\']') # delete
      expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_admin) + '\']')         # delete
    end

    scenario 'when delete any comment', js: true do
      within "#comment_#{comment_guest.id}" do
        find('.comment-delete-link').click
        page.driver.browser.switch_to.alert.accept
      end

      within "#comment_#{comment_account_owner.id}" do
        find('.comment-delete-link').click
        page.driver.browser.switch_to.alert.accept
      end

      within "#comment_#{comment_admin.id}" do
        find('.comment-delete-link').click
        page.driver.browser.switch_to.alert.accept
      end

      expect(page).not_to have_content comment_guest.body
      expect(page).not_to have_content comment_account_owner.body
      expect(page).not_to have_content comment_admin.body

      expect(page).not_to have_link user_guest.name
      expect(page).not_to have_link user.name
      expect(page).not_to have_link user_admin.name
    end
  end # account owner
end # User available comments

# =====================================
# role: admin
# =====================================
feature 'Admin available comments', %q{
  As an admin
  I am available to comment
} do

  let(:user)       { create :user }
  let(:user_guest) { create :user }
  let(:user_admin) { create :user_admin }
  let(:account)    { create :account, user: user, visible: true }
  let!(:comment_guest) { create :comment, user: user_guest, account: account }
  let!(:comment_account_owner) { create :comment, user: user, account: account }
  let!(:comment_admin) { create :comment, user: user_admin, account: account }

  before do
    sign_in user_admin
    visit account_path(account)
    click_on 'Коментарі'
  end

  scenario 'admin available to comments' do
    expect(current_path).to eq account_path(account)
    expect(page).to have_content comment_guest.body
    expect(page).to have_content comment_account_owner.body
    expect(page).to have_content comment_admin.body
    
    expect(page).to have_link user_guest.name
    expect(page).to have_link user.name
    expect(page).to have_link user_admin.name    

    expect(page).to have_css('a[href=\'' + user_path(user_guest) + '\']')
    expect(page).to have_css('a[href=\'' + user_path(user) + '\']')
    expect(page).to have_css('a[href=\'' + user_path(user_admin) + '\']')
    expect(page).to have_css('#new_comment')
  end

  scenario 'when admin creates a new comment', js: true do
    fill_in 'comment[body]', with: "#{user_admin.name} test comment"

    expect { click_on 'Додати коментар' }.to change(account.reload.comments, :count).by(1)
    expect(current_path).to eq account_path(account)
    expect(page).to have_content "#{user_admin.name} test comment"
  end

  scenario 'admin able to edit only your own comment' do
    expect(page).to have_css("#comment-#{comment_admin.id}-edit")
    expect(page).not_to have_css("#comment-#{comment_account_owner.id}-edit")
    expect(page).not_to have_css("#comment-#{comment_guest.id}-edit")
  end

  scenario 'when edit own comment with invalid data', js: true do
    within "#comment_#{comment_admin.id}" do
      find('.comment-edit-link').click
    end

    within "#comment-#{comment_admin.id}-edit" do
      fill_in 'comment[body]', with: ''
      click_on 'Зберегти'
      expect(page).to have_content 'Body can\'t be blank'
    end
    expect(comment_admin.reload.body).not_to be_empty
  end

  scenario 'when edit own comment with valid data', js: true do
    within "#comment_#{comment_admin.id}" do
      find('.comment-edit-link').click
    end

    within "#comment-#{comment_admin.id}-edit" do
      fill_in 'comment[body]', with: 'Admin edited comment'
      click_on 'Зберегти'
    end

    within "#comment_#{comment_admin.id}" do
      expect(page).to have_content 'Admin edited comment'
    end
    expect(comment_admin.reload.body).to eq 'Admin edited comment'
  end

  scenario 'admin able to delete any comment' do
    expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_guest) + '\']')         # delete
    expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_account_owner) + '\']') # delete
    expect(page).to have_css('a[href=\'' + account_comment_path(account, comment_admin) + '\']')         # delete
  end

  scenario 'when delete any comment', js: true do
    within "#comment_#{comment_guest.id}" do
      find('.comment-delete-link').click
      page.driver.browser.switch_to.alert.accept
    end

    within "#comment_#{comment_account_owner.id}" do
      find('.comment-delete-link').click
      page.driver.browser.switch_to.alert.accept
    end

    within "#comment_#{comment_admin.id}" do
      find('.comment-delete-link').click
      page.driver.browser.switch_to.alert.accept
    end

    expect(page).not_to have_content comment_guest.body
    expect(page).not_to have_content comment_account_owner.body
    expect(page).not_to have_content comment_admin.body

    expect(page).not_to have_link user_guest.name
    expect(page).not_to have_link user.name
    expect(page).not_to have_link user_admin.name
  end

end # Admin available comments
