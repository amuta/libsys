# frozen_string_literal: true

module Book::Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(q) {
      next all if q.blank?

      qn      = ActiveRecord::Base.sanitize_sql_like(q.to_s.downcase)
      pattern = "%#{qn}%"
      author_role = Contribution.roles[:author]

      joins(<<~SQL)
        LEFT JOIN contributions
          ON contributions.catalogable_type = 'Book'
         AND contributions.catalogable_id   = books.id
         AND contributions.role             = #{author_role}
         AND contributions.agent_type       = 'Person'
        LEFT JOIN people       ON people.id       = contributions.agent_id
        LEFT JOIN book_genres  ON book_genres.book_id = books.id
        LEFT JOIN genres       ON genres.id       = book_genres.genre_id
      SQL
        .where(
          "LOWER(books.title) LIKE :q OR LOWER(people.name) LIKE :q OR LOWER(genres.name) LIKE :q",
          q: pattern
        )
        .distinct
    }
  end
end
