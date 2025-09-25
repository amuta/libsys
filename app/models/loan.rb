class Loan < ApplicationRecord
  include Loan::Defaults
  include Loan::Rules

  belongs_to :copy
  belongs_to :user
  belongs_to :loanable, polymorphic: true

  enum :status, { active: 0, returned: 1 }

  scope :overdue_now, -> { active.where("due_at < ?", Time.current) }

  def overdue?
    active? && due_at.present? && due_at < Time.current
  end

  def status_now
    return "returned" if returned?
    return "overdue"  if overdue?
    "active"
  end
end
