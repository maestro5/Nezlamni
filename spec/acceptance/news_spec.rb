require_relative '../acceptance_helper'

feature 'User add and edit news', %q{
  As a user
  I want to be able to add and edit news (article)
} do

  let(:user) { create :user }
  let(:account) { user.account }

  before { account.update_attribute(:visible, true) }

  scenario 'when user adds and edits news' do
    sign_in user
    click_on 'Моя сторінка'
    click_on 'Новини'
    
    # adds new inside article
    click_on 'Додати'
    fill_in 'article[title]', with: 'Test inside article title'
    fill_in 'article[description]', with: 'Test description'

    expect { click_on 'Зберегти' }.to change(Article, :count).by(1)

    article = account.articles.first
    expect(current_path).to eq article_path(article)
    expect(page).to have_content article.title
    expect(page).to have_content article.description
    expect(page).to have_link 'Редагувати'
    expect(page).to have_link 'Видалити'

    click_on 'Моя сторінка'
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

    # edits, change link from inside to outside
    click_on 'Моя сторінка'
    click_on 'Новини'
    within '.article' do
      click_on 'Редагувати'
    end

    expect(current_path).to eq edit_article_path(article)

    new_article_title = 'Test outside article title'
    outside_link = 'www.test.com'
    fill_in 'article[title]', with: new_article_title
    fill_in 'article[link]', with: outside_link
    expect { click_on 'Зберегти' }.to change(account.articles, :count).by(0)

    expect(current_path).to eq article_path(article)
    expect(page).to have_content new_article_title

    click_on 'Моя сторінка'
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
  end # when user adds and edits news
end # User add and edit news

feature 'Admin add and edit user news', %q{
  As a user
  I want to be able to add and edit user news (article)
} do

  let(:user_admin) { create :user_admin }
  let(:user) { create :user }
  let(:account) { user.account }

  before do
    account.update_attributes(
      name: 'user',
      visible: true
    )
  end

  scenario 'when admin adds and edits user news' do
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

    article = account.articles.first
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

    # edits inside user news into outside
    find('a.avatar').click
    within '.section-tabs' do
      click_on 'Новини'
      within '.article' do
        click_on 'Редагувати'
      end
    end

    expect(current_path).to eq edit_article_path(article)

    new_article_title = 'Test outside article title'
    outside_link = 'www.test.com'
    fill_in 'article[title]', with: new_article_title
    fill_in 'article[link]', with: outside_link   

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

    # hide user article, visible = false
    visit articles_path
    click_on 'Приховувати'
    expect(page).to have_selector 'tr.danger'
    expect(page).to have_link new_article_title
    expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
    expect(page).to have_link article.account.name

    visit root_path
    expect(page).not_to have_selector '.article'

    find('a.avatar').click
    within '.section-tabs' do
      expect(page).to have_selector '.article'
    end

    # show user news, visible = true
    visit articles_path
    click_on 'Показувати'
    expect(page).not_to have_selector 'tr.danger'
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
      within '.article' do
        expect(page).to have_link new_article_title
        expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
        expect(page).to have_content article.description
        expect(page).to have_link 'детальніше' if article.description.length >= 300
      end
    end
  end # when admin adds and edits user news
end # Admin add and edit user news

feature 'Admin add and edit own news', %q{
  As an admin
  I want to be able to add and edit my own news (article)
} do

  let(:user_admin) { create :user_admin }
  let(:account) { user_admin.account }

  before { account.update_attributes name: 'admin', visible: true }

  scenario "when admin adds and edits article" do
    sign_in user_admin
    click_on 'Новини'

    expect(current_path).to eq articles_path

    # adds new inside user article
    click_on 'Додати'
    fill_in 'article[title]', with: 'Test inside article title'
    fill_in 'article[description]', with: 'Test description'

    expect { click_on 'Зберегти' }.to change(account.articles, :count).by(1)

    article = account.articles.first
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

    # edits inside user article into outside
    click_on 'Новини'
    click_on 'Редагувати'

    expect(current_path).to eq edit_article_path(article)

    new_article_title = 'Test outside article title'
    outside_link = 'www.test.com'
    fill_in 'article[title]', with: new_article_title
    fill_in 'article[link]', with: outside_link   

    expect { click_on 'Зберегти' }.to change(account.articles, :count).by(0)

    expect(current_path).to eq article_path(article)
    expect(page).to have_content new_article_title

    click_on 'Новини'
    expect(page).not_to have_selector 'tr.danger'
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

    # hide news, visible = false
    visit articles_path
    click_on 'Приховувати'
    expect(page).to have_selector 'tr.danger'
    expect(page).to have_link new_article_title
    expect(page).to have_css('a[href=\'http://' + outside_link + '\']')
    expect(page).to have_link article.account.name

    visit root_path
    expect(page).not_to have_selector '.article'

    # show news, visible = true
    visit articles_path
    click_on 'Показувати'
    expect(page).not_to have_selector 'tr.danger'
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
  end # when admin adds and edits own news
end # Admin add and edit news