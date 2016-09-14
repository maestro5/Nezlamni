FactoryGirl.define do
  factory :image do
    image Rack::Test::UploadedFile.new('spec/test.jpg','image/jpg')
  end
end
