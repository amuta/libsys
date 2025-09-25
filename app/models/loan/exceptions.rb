module Loan::Exceptions
  class NotAvailable < StandardError; end
  class AlreadyBorrowed < StandardError; end
end
