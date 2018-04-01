FactoryGirl.define do
  factory :account do
    name Faker::Name.name
    birthday_on (Time.now - 10.year).to_date
    goal Faker::Lorem.sentence
    budget 21000
    deadline_on (Time.now + 2.month).to_date
    payment_details "#{Faker::Bank.name}, #{Faker::Bank.swift_bic}, #{Faker::Bank.iban}"
    phone_number Faker::PhoneNumber.cell_phone
    contact_person Faker::Name.name
    backers 0
    collected 0.0
    overview Faker::Lorem.paragraph
  end
end
