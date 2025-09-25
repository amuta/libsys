FactoryBot.define do
  factory :contribution do
    association :catalogable, factory: :book
    association :agent, factory: :person
    role { :author }
    position { 1 }
  end
end