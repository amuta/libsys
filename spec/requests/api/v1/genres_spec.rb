require 'rails_helper'

RSpec.describe "Api::V1::Genres", type: :request do
  describe "GET /search" do
    it "returns http success" do
      user = create(:user)
      sign_in(user)
      get "/api/v1/genres/search"
      expect(response).to have_http_status(:success)
    end
  end
end
