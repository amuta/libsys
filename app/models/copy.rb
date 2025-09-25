class Copy < ApplicationRecord
  belongs_to :loanable, polymorphic: true
  enum :status, { available: 0, loaned: 1 }
  has_one :active_loan, -> { active }, class_name: "Loan"
  validates :barcode, presence: true, uniqueness: true
end
