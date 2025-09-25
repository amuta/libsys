module Catalogable
  extend ActiveSupport::Concern

  included do
    has_many :contributions, as: :catalogable, dependent: :destroy
  end

  def contributors(role:, agent_type: "Person")
    contributions.includes(:agent).where(role:, agent_type:)
  end

  def contributor_agents(role:, agent_type: "Person")
    contributors(role:, agent_type:).map(&:agent)
  end

  # replace-all
  def replace_contributors!(role:, agent_type: "Person", agent_ids:)
    contributions.where(role:, agent_type:).delete_all
    ids = Array(agent_ids).map!(&:to_i).uniq
    return if ids.empty?

    now = Time.current
    rows = ids.map do |agent_id|
      {
        catalogable_type: self.class.name,
        catalogable_id:   self.id,
        agent_type:       agent_type,
        agent_id:         agent_id,
        role:             Contribution.roles.fetch(role),
        position:         1,
        created_at:       now,
        updated_at:       now
      }
    end
    Contribution.insert_all!(rows)
  end
end
