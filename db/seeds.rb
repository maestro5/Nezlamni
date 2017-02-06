lorem = 'Lorem ipsum dolor sit amet, nibh nominati ' +
  'voluptatum sit te, per ad democritum scriptorem dissentiet. ' +
  'Forensibus dissentias ut vim. Per utroque efficiantur at. ' +
  'Quando probatus gubergren ex mel, wisi accommodare id nec. ' +
  "Erat deterruisset et sit, insolens interpretaris sea ea, wisi commune praesent pri eu.\n"
  'Melius periculis in mei, ea dicant accusata facilisis nec, ' +
  'ne sed velit recteque scriptorem. Scripta delicatissimi et est, ' +
  'doming ancillae inciderint sit ne. Elit sonet everti an sed. ' +
  'Eu ullum dolor scriptorem est, te sit reque viris persecuti.'

# ======================================================
# User
# ======================================================
user_admin = User.create!(email: 'admin@example.com', password: 'password', admin: true)
user_one = User.create!(email: 'user_one@example.com', password: 'password')
user_two = User.create!(email: 'user_two@example.com', password: 'password')

# ======================================================
# Account
# ======================================================
payment_details = 'Благодійна Організація «Незламні», ' + 
  'МФО 311744, Р-р 24031010379590, Код 29819402, ' +
  'Призначення: добровільні пожертвування'

# user_one
account1 = user_one.accounts.create!(
  name: 'Прокопчук Віктор Сергійович',
  birthday_on: Time.parse('19/05/2007'),
  goal: 'Лікування',
  budget: 71000,
  deadline_on: Time.now + 3.month,
  phone_number: '+38(067)503-17-99',
  contact_person: 'Людмила Сергіївна',
  payment_details: payment_details,
  overview: lorem,
  visible: true,
  locked: false
)

account2 = user_one.accounts.create!(
  name: 'Фус Катерина Вікторівна',
  birthday_on: Time.parse('09/02/2003'),
  goal: 'Лікування',
  budget: 21000,
  deadline_on: Time.now + 2.month,
  phone_number: '+38(067)503-17-99',
  contact_person: 'Людмила Сергіївна',
  payment_details: payment_details,
  overview: lorem,
  collected: 17981,
  backers: 19,
  visible: true,
  locked: false
)

user_one.accounts.create!(
  name: 'Борочко Людмила Вікторівна',
  birthday_on: Time.parse('19/02/2003'),
  goal: 'Лікування',
  budget: 20000,
  deadline_on: Time.now + 4.month,
  phone_number: '+38(067)530-07-09',
  contact_person: 'Людмила Сергіївна',
  payment_details: payment_details,
  overview: lorem,
  collected: 10981,
  backers: 15,
  visible: true,
  locked: false
)

user_one.accounts.create!(
  name: 'Біла Людмила Анатоліївна',
  birthday_on: Time.parse('17/11/2006'),
  goal: 'Лікування',
  budget: 55000,
  deadline_on: Time.now + 6.month,
  phone_number: '+38(067)503-17-99',
  contact_person: 'Людмила Сергіївна',
  payment_details: payment_details,
  overview: lorem,
  visible: false,
  locked: false
)

# user_two
user_two.accounts.create!(
  name: 'Бойко Вадим Анатолійович',
  birthday_on: Time.parse('21/06/2008'),
  goal: 'Лікування',
  budget: 50000,
  deadline_on: Time.now + 4.month,
  phone_number: '+38(067)313-79-19',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  collected: 23719,
  backers: 39,
  visible: true,
  locked: false
)

account3 = user_two.accounts.create!(
  name: 'Ткаченко Світлана Миколаївна',
  birthday_on: Time.parse('22/08/2005'),
  goal: 'Лікування',
  budget: 60000,
  deadline_on: Time.now + 4.month,
  phone_number: '+38(067)313-79-19',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  visible: true,
  locked: false
)

user_two.accounts.create!(
  name: 'Олійник Олег Андрійович',
  birthday_on: Time.parse('30/10/2009'),
  goal: 'Лікування',
  budget: 100000,
  deadline_on: Time.now + 7.month,
  phone_number: '+38(067)313-79-19',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  visible: true,
  locked: true
)

user_two.accounts.create!(
  name: 'Галаєнко Андрій Олексійович',
  birthday_on: Time.parse('13/11/2005'),
  goal: 'Лікування',
  budget: 11000,
  deadline_on: Time.now + 6.month,
  phone_number: '+38(067)313-97-91',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  visible: true,
  locked: true
)

user_two.accounts.create!(
  name: 'Трублаєвський Олексій Андрійович',
  birthday_on: Time.parse('27/07/2010'),
  goal: 'Лікування',
  budget: 100000,
  deadline_on: Time.now + 11.month,
  phone_number: '+38(067)253-87-19',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  collected: 981,
  backers: 3,
  visible: true,
  locked: true
)

user_two.accounts.create!(
  name: 'Гойко Тамара Олексіївна',
  birthday_on: Time.parse('17/06/2011'),
  goal: 'Лікування',
  budget: 12000,
  deadline_on: Time.now + 4.month,
  phone_number: '+38(067)523-70-10',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  collected: 9081,
  backers: 21,
  visible: true,
  locked: true
)

user_two.accounts.create!(
  name: 'Палій Анатолій Анатолійович',
  birthday_on: Time.parse('27/07/2003'),
  goal: 'Лікування',
  budget: 15000,
  deadline_on: Time.now + 3.month,
  phone_number: '+38(067)378-44-11',
  contact_person: 'Микола Григорович',
  payment_details: payment_details,
  overview: lorem,
  visible: true,
  locked: true
)

# ======================================================
# Product
# ======================================================
product_one = account2.products.create!(
  contribution: 333,
  title: 'Продукт користувача',
  description: lorem,
  backers: 1,
  remainder: 19
)

# ======================================================
# Order
# ======================================================
product_one.orders.create!(
  account: account2,
  contribution: 333,
  recipient: 'Сергієнко Віктор Сергійович',
  phone: '+380673987197',
  email: 'customer@example.com',
  address: 'м. Вінниця, склад №1'
)

account2.orders.create!(
  product: account2.products.first,
  contribution: 150,
  recipient: 'Поліщук Людмила Юріївна'
)

# ======================================================
# Article
# ======================================================
account1.articles.create!(
  title: 'Зовнішня стаття користувача',
  description: lorem,
  link: 'http://youtube.com'
)
account2.articles.create!(
  title: 'Внутрішня стаття від користувача',
  description: lorem,
  link: ''
)
account3.articles.create!(
  title: 'Внутрішня стаття від користувача',
  description: lorem,
  link: ''
)

Article.create!(
  title: 'Внутрішня стаття від адміністратора',
  description: lorem,
  link: ''
)
Article.create!(
  title: 'Зовнішня стаття від адміністратора',
  description: lorem,
  link: 'http://youtube.com'
)

# ======================================================
# Comment
# ======================================================
account1.comments.create!(user: user_two, body: 'Guest comment')
account1.comments.create!(user: user_one, body: 'Account owner comment')
account1.comments.create!(user: user_admin, body: 'Admin comment')
account3.comments.create!(user: user_one, body: 'Guest comment')
