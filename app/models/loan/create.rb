class Loan::Create
  def self.call!(user:, loanable:)
    Pundit.authorize(user, Loan, :create?)
    Copy.transaction do
      copy = loanable.copies.lock.available.first
      raise Loan::Exceptions::NotAvailable unless copy

      # Check if user already has an active loan for this loanable
      existing_loan = Loan.joins(:copy).where(user: user, loanable: loanable, status: :active).exists?
      raise Loan::Exceptions::AlreadyBorrowed if existing_loan

      loan = Loan.new(copy:, user:, loanable:)
      loan.save!
      copy.update!(status: :loaned)
      loan
    end
  end
end
