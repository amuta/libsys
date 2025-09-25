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

  def replace_contributors!(role:, agent_type: "Person", agent_ids:)
    contributions.where(role:, agent_type:).delete_all
    ids = Array(agent_ids).map!(&:to_i).uniq
    return if ids.empty?
    Contribution.insert_all!(ids.map { |id|
      {
        catalogable_type: self.class.name, catalogable_id: id,
        agent_type:, agent_id: id, role: Contribution.roles.fetch(role),
        position: 1, created_at: Time.current, updated_at: Time.current
      }
    })
  end
end
