class Person < ApplicationRecord
  has_many :contributions, as: :agent, dependent: :destroy
  has_many :books, through: :contributions, source: :catalogable, source_type: "Book"
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :search, ->(q) { q.present? ? where("LOWER(name) LIKE ?", "%#{q.downcase}%") : all }
end
