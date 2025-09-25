module AuthHelper
  def sign_in(user)
    post "/api/v1/session", params: { email_address: user.email_address, password: "password" }, headers: { "Accept" => "application/json" }
    expect(response).to have_http_status(:created)
  end
  def sign_out
    delete "/api/v1/session"
  end
end
RSpec.configure { |c| c.include AuthHelper, type: :request }