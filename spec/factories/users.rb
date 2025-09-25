FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "u#{n}@ex.com" }
    password { "password" }
    name { "U" }
    role { :member }
    trait(:librarian) { role { :librarian } }
  end
end