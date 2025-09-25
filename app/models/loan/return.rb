class Loan::Return
  def self.call!(librarian:, loan:)
    Pundit.authorize(librarian, loan, :return?)
    Copy.transaction do
      raise Loan::Exceptions::AlreadyReturned if loan.returned?
      loan.update!(returned_at: Time.current, status: :returned)
      loan.copy.update!(status: :available)
      true
    end
  end
end
