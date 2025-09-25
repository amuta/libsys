class Genre < ApplicationRecord
  has_many :books, dependent: :nullify
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :search, ->(q) { q.present? ? where("LOWER(name) LIKE ?", "%#{q.downcase}%") : all }
end
