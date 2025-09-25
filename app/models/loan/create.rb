class Loan::Create
  def self.call(user:, loanable:)
    Pundit.authorize(user, Loan, :create?)
    Copy.transaction do
      copy = loanable.copies.lock.available.first or raise ActiveRecord::RecordInvalid, loanable
      loan = Loan.create!(copy:, user:, loanable:)
      copy.update!(status: :loaned)
      loan
    end
  end
end
