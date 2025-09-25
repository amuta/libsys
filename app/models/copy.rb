class Copy < ApplicationRecord
  belongs_to :loanable, polymorphic: true
  enum :status, { available: 0, loaned: 1 }, default: :available
  has_many :loans
  has_one :active_loan, -> { where(status: Loan.statuses[:active]) }, class_name: "Loan"
  validates :barcode, presence: true, uniqueness: true
end
