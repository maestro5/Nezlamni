require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor unavailable profile page', %q{
  As a visitor
  I can't go to profile page
} do

  let!(:user) { create :user }

  scenario 'visitor does not have  link' do
    visit root_path
    expect(page).not_to have_link user_path(user)
  end

  scenario 'when visitor visit the profile page' do
    visit user_path(user)
    expect(current_path).to eq user_path(user)
    expect(page).not_to have_link 'Редагувати'
  end
end

# =====================================
# role: user
# =====================================
feature 'User available profile page', %q{
  As an user
  I available profile page
} do

  let!(:user)     { create :user }
  let!(:user_two) { create :user }

  before do
    sign_in user
    visit root_path
  end

  scenario 'user have a profile link' do
    expect(page).to have_css('a[href=\'' + user_path(user) + '\']')
  end

  scenario 'when user goes to the profile page' do
    find('#profile').click
    expect(current_path).to eq user_path(user)
    expect(page).to have_content user.name
    expect(page).to have_link 'Редагувати'
  end

  scenario 'when user try view the profile of another user' do
    visit user_path(user_two)
    expect(current_path).to eq user_path(user_two)
    expect(page).not_to have_link 'Редагувати'
  end

  context 'when user edits profile' do
    before do
      find('#profile').click
      click_on 'Редагувати'
    end
    
    scenario 'show edits profile page' do
      expect(current_path).to eq edit_user_path(user)
    end

    scenario 'save changes' do
      fill_in 'user[name]', with: 'Amir Origin'
      attach_file('user[avatar]', 'spec/test.jpg')

      expect { click_on 'Зберегти' }
        .to change { user.reload.name }.from('Bob').to('Amir Origin')
        .and change { user.reload.avatar? }.from(false).to(true)
      expect(current_path).to eq user_path(user)
      expect(page).to have_content 'Amir Origin'
      expect(page).to have_css("img[src*='test.jpg']")
    end
  end # when user edits profile
end # User available profile page

# =====================================
# role: admin
# =====================================
feature 'Admin available profile page', %q{
  As an admin
  I available profile page
} do

  let!(:user_admin) { create :user_admin }
  let!(:user)       { create :user }

  before do
    sign_in user_admin
    visit root_path
  end

  scenario 'admin have a profile link' do
    expect(page).to have_css('a[href=\'' + user_path(user_admin) + '\']')
  end

  scenario 'when admin goes to the profile page' do
    find('#profile').click
    expect(current_path).to eq user_path(user_admin)
    expect(page).to have_content user_admin.name
    expect(page).to have_link 'Редагувати'
  end

  context 'when admin edits own profile' do
    before do
      find('#profile').click
      click_on 'Редагувати'
    end

    scenario 'show edit profile page' do
      expect(current_path).to eq edit_user_path(user_admin)
    end

    scenario 'save changes' do
      fill_in 'user[name]', with: 'Amir Origin'
      attach_file('user[avatar]', 'spec/test.jpg')

      expect { click_on 'Зберегти' }
        .to change { user_admin.reload.name }.from('Bill').to('Amir Origin')
        .and change { user_admin.reload.avatar? }.from(false).to(true)
      expect(current_path).to eq user_path(user_admin)
      expect(page).to have_content 'Amir Origin'
      expect(page).to have_css("img[src*='test.jpg']")
    end
  end # when admin edits own profile

  context 'when admin edits the profile of another user' do
    before do
      visit user_path(user)
      click_on 'Редагувати'
    end

    scenario 'show edit profile page' do
      expect(current_path).to eq edit_user_path(user)
    end

    scenario 'save changes' do
      fill_in 'user[name]', with: 'Tony Stark'
      attach_file('user[avatar]', 'spec/test.jpg')

      expect { click_on 'Зберегти' }
        .to change { user.reload.name }.from('Bob').to('Tony Stark')
        .and change { user.reload.avatar? }.from(false).to(true)
      expect(current_path).to eq user_path(user)
      expect(page).to have_content 'Tony Stark'
      expect(page).to have_css("img[src*='test.jpg']")
    end
  end # when admin edits the profile of another user
end # Admin available profile page
