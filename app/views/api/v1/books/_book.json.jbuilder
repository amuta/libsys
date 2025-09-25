json.extract! book, :id, :title, :isbn, :language
json.available_copies book.available_copies_count
json.genre do
  if book.genre
    json.extract! book.genre, :id, :name
  else
    json.null!
  end
end
json.authors book.contributions.where(role: :author, agent_type: "Person").includes(:agent).order(:position) do |c|
  json.id   c.agent_id
  json.name c.agent.name
end
