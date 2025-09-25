require "rails_helper"
RSpec.describe "Session", type: :request do
  let!(:user) { create(:user) }

  it "logs in with valid creds" do
    post "/api/v1/session", params: { email_address: user.email_address, password: "password" }
    expect(response).to have_http_status(:created)
    expect(json.dig(:user, :email_address)).to eq(user.email_address)
  end

  it "rejects invalid creds" do
    post "/api/v1/session", params: { email_address: user.email_address, password: "x" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "whoami and logout" do
    sign_in(user)
    get "/api/v1/session"
    expect(response).to have_http_status(:ok)
    delete "/api/v1/session"
    expect(response).to have_http_status(:no_content)
    get "/api/v1/session"
    expect(response).to have_http_status(:unauthorized)
  end
end
