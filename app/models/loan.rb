class Loan < ApplicationRecord
  belongs_to :copy
  belongs_to :user
  belongs_to :loanable, polymorphic: true
end
