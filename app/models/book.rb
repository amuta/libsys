class Book < ApplicationRecord
  include Loanable
  include Catalogable
  include Book::Searchable

  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres

  validates :title, presence: true
  validates :isbn, format: { with: /\A[0-9X-]+\z/i }, allow_blank: true

  # typed helpers remain
  def authors = contributor_agents(role: :author, agent_type: "Person")
  def author_ids = contributions.where(role: :author, agent_type: "Person").pluck(:agent_id)
  def author_ids=(ids)
    replace_contributors!(role: :author, agent_type: "Person", agent_ids: ids)
  end
end
