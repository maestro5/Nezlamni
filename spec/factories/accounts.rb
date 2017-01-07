FactoryGirl.define do
  factory :account do
    name 'Bob Green'
    birthday_on Time.parse('15/07/2007')
    goal 'Treatment'
    budget 21000
    deadline_on Time.now + 2.month
    payment_details 'some Bank account: 234487102'
  end
end
