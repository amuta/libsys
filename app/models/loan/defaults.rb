# app/models/loan/defaults.rb
module Loan::Defaults
  extend ActiveSupport::Concern
  DEFAULT_LOAN_DAYS = 14
  included { before_validation :set_defaults, on: :create }
  private
  def set_defaults
    self.borrowed_at ||= Time.current
    self.due_at      ||= borrowed_at + DEFAULT_LOAN_DAYS.days
    self.status      ||= :active
  end
end
