FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@test.com" }
    name 'Bob'
    password 'password'
  end

  factory :user_admin, class: User do
    email 'admin@test.com'
    name 'Bill'
    password 'password'
    admin true
  end
end
