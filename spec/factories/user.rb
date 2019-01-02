FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    name Faker::Name.name
    password 'password'
  end

  # factory :user_admin, class: User do
  #   email 'admin@test.com'
  #   name 'Bill'
  #   password 'password'
  #   admin true
  # end

  trait :admin do
    email 'admin@test.com'
    admin true
  end

end
