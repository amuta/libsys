FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book #{n}" }
    isbn { "9780132350884" }
    language { "en" }
  end
end