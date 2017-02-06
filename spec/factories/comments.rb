FactoryGirl.define do
  factory :comment do
    sequence(:body) { |n| "Test comment #{n}" }
  end
end
