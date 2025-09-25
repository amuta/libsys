require 'rails_helper'

RSpec.describe "Api::V1::Loans", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/loans/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /return" do
    it "returns http success" do
      get "/api/v1/loans/return"
      expect(response).to have_http_status(:success)
    end
  end
end
