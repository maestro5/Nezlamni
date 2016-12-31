require_relative '../acceptance_helper'

# =====================================
# role: user
# =====================================
feature 'User add and edit news', %q{
  As a user
  I want to be able to add and edit news (article)
} do

  let(:user) { create :user }
  let(:account) { create(:account, user: user, visible: true) }

  scenario 'when user adds news' do
    sign_in user
    visit account_path account
    click_on 'Новини'
    
    # adds new inside article
    click_on 'Додати'
    fill_in 'article[title]', with: 'Test inside article title'
    fill_in 'article[description]', with: 'Test description'

    expect { click_on 'Зберегти' }.to change(Article, :count).by(1)
    expect(page).to have_content 'Test inside article title'
    expect(page).to have_content 'Test description'
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Видалити'

    article = Article.last

    visit account_path account
    click_on 'Новини'
    within '.article' do
      expect(page).to have_link article.title
      expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
      expect(page).to have_content article.description
      expect(page).to have_link 'детальніше' if article.description.length >= 300
      expect(page).to have_link 'Редагувати'
      expect(page).to have_link 'Видалити'
    end

    visit root_path
    within '.article' do
      expect(page).to have_link article.title
      expect(page).to have_content article.description
      expect(page).to have_link 'детальніше' if article.description.length >= 300
    end
  end # when user adds a news

  context 'when news present' do
    let!(:article) { create(:article, account: account) }
    let(:new_article_title) { 'Test outside article title' }
    let(:outside_link) { 'www.test.com' }

    scenario 'when user edits news' do
      sign_in user
      visit account_path account
      click_on 'Новини'
      within '.article' do
        click_on 'Редагувати'
      end
      expect(current_path).to eq edit_article_path(article)

      # change article from inside to outside
      fill_in 'article[title]', with: new_article_title
      fill_in 'article[link]', with: outside_link
      expect { click_on 'Зберегти' }.to change(account.articles, :count).by(0)
      expect(current_path).to eq article_path(article)
      expect(page).to have_content new_article_title

      visit account_path account
      click_on 'Новини'
      within '.article' do
        expect(page).to have_link new_article_title
        expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
        expect(page).to have_link 'Редагувати'
        expect(page).to have_link 'Видалити'
      end

      visit root_path
      within '.article' do
        expect(page).to have_link new_article_title
        expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end
    end
  end # when user adds and edits news
end # User add and edit news

# =====================================
# role: admin
# =====================================
feature 'Admin add and edit user news', %q{
  As a user
  I want to be able to add and edit user news (article)
} do

  let(:user_admin) { create :user_admin }
  let(:user) { create :user }
  let!(:account) { create(:account, visible: true) }

  scenario 'when admin adds user news' do
    sign_in user_admin
    find('a.avatar').click
    within '.section-tabs' do
      click_on 'Новини'
    end
    
    # adds new inside user article
    click_on 'Додати'
    fill_in 'article[title]', with: 'Test inside article title'
    fill_in 'article[description]', with: 'Test description'

    expect { click_on 'Зберегти' }.to change(account.articles, :count).by(1)

    article = Article.last
    expect(current_path).to eq article_path(article)
    expect(page).to have_content article.title
    expect(page).to have_content article.description
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Видалити'

    click_on 'Новини'
    expect(page).not_to have_selector 'tr.danger'
    expect(page).to have_link article.title
    expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
    expect(page).to have_link article.account.name

    visit root_path
    within '.article' do
      expect(page).to have_link article.title
      expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
      expect(page).to have_content article.description
      expect(page).to have_link 'детальніше' if article.description.length >= 300
    end

    find('a.avatar').click
    within '.section-tabs' do
      click_on 'Новини'

      within '.article' do
        expect(page).to have_link article.title
        expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
        expect(page).to have_link 'Редагувати'
        expect(page).to have_link 'Видалити'
      end
    end # .section-tabs
  end # when admin adds user news

  context 'when user news present' do
    let!(:article) { create(:article, account: account) }
    let(:new_article_title) { 'Test outside article title' }
    let(:outside_link) { 'www.test.com' }

    scenario 'when admin edits user news' do
      sign_in user_admin

      # change article from inside to outside
      find('a.avatar').click
      within '.section-tabs' do
        click_on 'Новини'
        within '.article' do
          click_on 'Редагувати'
        end
      end

      expect(current_path).to eq edit_article_path(article)

      fill_in 'article[title]', with: new_article_title
      fill_in 'article[link]',  with: outside_link
      expect { click_on 'Зберегти' }.to change(account.articles, :count).by(0)

      expect(current_path).to eq article_path(article)
      expect(page).to have_content new_article_title

      click_on 'Новини'
      expect(page).to have_link new_article_title
      expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
      expect(page).to have_link article.account.name

      visit root_path
      within '.article' do
        expect(page).to have_link new_article_title
        expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end

      find('a.avatar').click
      within '.section-tabs' do
        click_on 'Новини'
        within '.article' do
          expect(page).to have_link new_article_title
          expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
          expect(page).to have_content article.description
          expect(page).to have_link 'детальніше' if article.description.length >= 300
          expect(page).to have_link 'Редагувати'
          expect(page).to have_link 'Видалити'
        end
      end # .section-tabs    
    end # when admin edits user news

    scenario 'when admin hide user article' do
      sign_in user_admin
      visit articles_path
      click_on 'Приховувати'
      expect(page).to have_selector 'tr.danger'
      expect(page).to have_link article.title
      expect(page).to have_link article.account.name

      visit root_path
      expect(page).not_to have_selector '.article'

      find('a.avatar').click
      within '.section-tabs' do
        expect(page).to have_selector '.article'
      end
    end # when admin hide user article

    scenario 'when admin show user article' do
      article.update_attribute(:visible, false)

      sign_in user_admin
      visit articles_path
      click_on 'Показувати'
      expect(page).not_to have_selector 'tr.danger'
      expect(page).to have_link article.title
      expect(page).to have_link article.account.name

      visit root_path
      within '.article' do
        expect(page).to have_link article.title
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end

      find('a.avatar').click
      within '.section-tabs' do
        within '.article' do
          expect(page).to have_link article.title
          expect(page).to have_content article.description
          expect(page).to have_link 'детальніше' if article.description.length >= 300
        end
      end
    end # when admin show user article
  end # when user news present
end # Admin add and edit user news

feature 'Admin adds and edits own news', %q{
  As an admin
  I want to be able to add and edit my own news (article)
} do

  let(:user_admin) { create :user_admin }
  let(:new_article_title) { 'Test outside article title' }
  let(:outside_link) { 'www.test.com' }

  before { sign_in user_admin }

  scenario "when admin adds news" do
    click_on 'Новини'
    expect(current_path).to eq articles_path

    # adds new inside user article
    click_on 'Додати'
    fill_in 'article[title]', with: 'Test inside article title'
    fill_in 'article[description]', with: 'Test description'
    expect { click_on 'Зберегти' }.to change(Article, :count).by(1)

    article = Article.last
    expect(current_path).to eq article_path(article)
    expect(page).to have_content article.title
    expect(page).to have_content article.description
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Видалити'

    click_on 'Новини'
    expect(page).not_to have_selector 'tr.danger'
    expect(page).to have_link article.title
    expect(page).to have_css('a[href=\'' + article_path(article) + '\']')

    visit root_path
    within '.article' do
      expect(page).to have_link article.title
      expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
      expect(page).to have_content article.description
      expect(page).to have_link 'детальніше' if article.description.length >= 300
    end
  end # when admin adds news

  context 'when news present' do
    let!(:article) { create(:article) }

    scenario "when admin edits news" do
      click_on 'Новини'
      click_on 'Редагувати'
      expect(current_path).to eq edit_article_path(article)

      # change inside article into outside
      fill_in 'article[title]', with: new_article_title
      fill_in 'article[link]',  with: outside_link
      expect { click_on 'Зберегти' }.to change(Article, :count).by(0)
      expect(current_path).to eq article_path(article)
      expect(page).to have_content new_article_title

      click_on 'Новини'
      expect(page).not_to have_selector 'tr.danger'
      expect(page).to have_link new_article_title
      expect(page).to have_css('a[href=\'http://' + outside_link + '\']')

      visit root_path
      within '.article' do
        expect(page).to have_link new_article_title
        expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end
    end # when admin edits news

    scenario 'when admin hide news' do
      visit articles_path
      click_on 'Приховувати'
      expect(page).to have_selector 'tr.danger'
      expect(page).to have_link article.title
      expect(page).to have_css('a[href=\'' + article_path(article) + '\']')

      visit root_path
      expect(page).not_to have_selector '.article'
    end # when admin hide news

    scenario 'when admin show news' do
      article.update_attribute(:visible, false)

      visit articles_path
      click_on 'Показувати'
      expect(page).not_to have_selector 'tr.danger'
      expect(page).to have_link article.title
      expect(page).to have_css('a[href=\'' + article_path(article) + '\']')

      visit root_path
      within '.article' do
        expect(page).to have_link article.title
        expect(page).to have_css('a[href=\'' + article_path(article) + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end
    end # when admin show news
  end # when news present
end # Admin add and edit news
