FactoryBot.define do
  factory :loan do
    copy
    user
    loanable { copy.loanable }
    borrowed_at { Time.current }
    due_at { 14.days.from_now }
    status { :active }
  end
end