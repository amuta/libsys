json.user do
  json.id    Current.user.id
  json.email Current.user.email
  json.role  Current.user.role
end