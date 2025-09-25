class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :loans, dependent: :restrict_with_error
  enum :role, { librarian: 0, member: 1 }, default: :member

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: -> { password_digest_changed? }
end
