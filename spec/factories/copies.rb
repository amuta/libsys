FactoryBot.define do
  factory :copy do
    association :loanable, factory: :book
    sequence(:barcode) { |n| "BC#{n}" }
    status { :available }
  end
end
