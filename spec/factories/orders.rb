FactoryGirl.define do
  factory :order do
    contribution 777
    recipient 'John Galt'
    phone '+38(067)781-91-15'
    email 'jgalt@test.com'
    address 'test address'    
  end
end
