require "rails_helper"
RSpec.describe "Lookups", type: :request do
  let!(:mem) { create(:user) }
  let!(:p1) { create(:person, name: "Joshua Bloch") }
  let!(:g1) { create(:genre, name: "Software") }

  it "searches people" do
    sign_in(mem)
    get "/api/v1/people/search", params: { q: "blo" }
    expect(response).to have_http_status(:ok)
    expect(json.map { _1[:id] }).to include(p1.id)
  end

  it "searches genres" do
    sign_in(mem)
    get "/api/v1/genres/search", params: { q: "soft" }
    expect(response).to have_http_status(:ok)
    expect(json.map { _1[:id] }).to include(g1.id)
  end
end
