require_relative '../acceptance_helper'

# =====================================
# role: visitor
# =====================================
feature 'Visitor unavailable users page', %q{
  As a visitor
  I can't go to users page
} do

  scenario 'visitor does not have a link' do
    visit root_path
    expect(page).not_to have_link 'Користувачі'
  end

  scenario 'when visitor goes to the users page ' do
    visit users_path
    expect(current_path).to eq new_user_session_path
  end
end

# =====================================
# role: user
# =====================================
feature 'User unavailable users page', %q{
  As a user
  I can't go to users page
} do

  let(:user) { create(:user) }
  before { sign_in user }

  scenario 'user does not have a link' do
    visit root_path
    expect(page).not_to have_link 'Користувачі'
  end

  scenario 'when user goes to the users page ' do  
    visit users_path
    expect(current_path).to eq root_path
  end
end

# =====================================
# role: admin
# =====================================
feature 'Admin available users page', %q{
  As an admin
  I can to users page
} do

  let(:user_admin) { create(:user_admin) }
  let!(:user)       { create(:user) }
  before { sign_in user_admin }

  scenario 'admin has a link' do
    visit root_path
    expect(page).to have_link 'Користувачі'
  end

  scenario 'when user goes to the users page ' do  
    click_on 'Користувачі'
    expect(current_path).to eq users_path
    expect(page).to have_content user_admin.email
    expect(page).to have_content user.email
    expect(page).to have_link 'Видалити', count: 2
  end
end
