class Contribution < ApplicationRecord
  belongs_to :catalogable, polymorphic: true
  belongs_to :agent,       polymorphic: true

  enum :role, {
    author: 0, co_author: 1, editor: 2, translator: 3,
    donor: 30, owner: 40, cataloger: 43, sponsor: 52, other: 99
  }

  validates :agent_id, uniqueness: { scope: %i[catalogable_type catalogable_id agent_type role] }
end
