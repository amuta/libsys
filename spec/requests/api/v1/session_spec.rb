require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/session/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/session/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/session/show"
      expect(response).to have_http_status(:success)
    end
  end
end
