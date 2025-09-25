json.user do
  json.id            @session.user.id
  json.email_address @session.user.email_address
  json.name          @session.user.name
  json.role          @session.user.role
end