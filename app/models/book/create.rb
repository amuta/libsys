# frozen_string_literal: true

class Book::Create
  def self.call!(attrs:, author_ids: [], genre_ids: [])
    Book.transaction do
      book = Book.create!(attrs)
      book.genre_ids  = Array(genre_ids).map!(&:to_i).uniq
      book.author_ids = Array(author_ids)
      book
    end
  end
end
