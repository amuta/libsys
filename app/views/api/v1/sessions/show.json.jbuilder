json.user do
  json.id            @user.id
  json.email_address @user.email_address
  json.name          @user.name
  json.role          @user.role
end
