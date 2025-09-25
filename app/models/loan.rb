class Loan < ApplicationRecord
  include Loan::Defaults
  include Loan::Rules
  belongs_to :copy
  belongs_to :user
  belongs_to :loanable, polymorphic: true
  enum :status, { active: 0, returned: 1, overdue: 2 }
end
