FactoryGirl.define do
  factory :user do
    email 'user@test.com'
    password 'password'
  end

  factory :user_admin, class: User do
    email 'admin@test.com'
    password 'password'
    admin true
  end
end
