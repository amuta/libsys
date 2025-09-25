FactoryBot.define do
  factory :person do
    sequence(:name) { |n| "Author #{n}" }
  end
end