require 'rails_helper'

RSpec.describe "Api::V1::Copies", type: :request do
  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/copies/destroy"
      expect(response).to have_http_status(:success)
    end
  end
end
