class Genre < ApplicationRecord
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :search, ->(q) { q.present? ? where("LOWER(name) LIKE ?", "%#{q.downcase}%") : all }
end
