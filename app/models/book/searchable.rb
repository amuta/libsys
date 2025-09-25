# frozen_string_literal: true

module Book::Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(q) {
      return all if q.blank?

      qn      = ActiveRecord::Base.sanitize_sql_like(q.to_s)
      pattern = "%#{qn}%"
      author_role = Contribution.roles[:author]

      joins(<<~SQL)
        LEFT JOIN contributions
          ON contributions.catalogable_type = 'Book'
         AND contributions.catalogable_id   = books.id
         AND contributions.role             = #{author_role.to_i}
         AND contributions.agent_type       = 'Person'
        LEFT JOIN people      ON people.id  = contributions.agent_id
        LEFT JOIN book_genres ON book_genres.book_id = books.id
        LEFT JOIN genres      ON genres.id  = book_genres.genre_id
      SQL
        .where("books.title ILIKE :q OR people.name ILIKE :q OR genres.name ILIKE :q", q: pattern)
        .distinct
    }
  end
end
