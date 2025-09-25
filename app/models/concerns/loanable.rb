module Loanable
  extend ActiveSupport::Concern
  included do
    has_many :copies, as: :loanable, dependent: :restrict_with_error
  end
  def available_copies_count = copies.available.count
  def loan_to!(user)            = Loan::Create.call!(user:, loanable: self)
  def return!(loan, librarian:) = Loan::Return.call!(librarian:, loan:)
end
