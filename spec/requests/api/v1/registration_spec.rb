require "rails_helper"

RSpec.describe "Api::V1::Registration", type: :request do
  describe "POST /api/v1/registration" do
    it "registers a user" do
      post "/api/v1/registration", params: { user: { name: "John", email_address: "new@x.tld", password: "secretpass", password_confirmation: "secretpass" } }
      expect(response).to have_http_status(:created)
      expect(json.dig(:user, :role)).to eq("member")
    end

    it "normalizes email" do
      post "/api/v1/registration", params: { user: { name: "A", email_address: "CASE@X.TLD", password: "secretpass", password_confirmation: "secretpass" } }
      expect(User.last.email_address).to eq("case@x.tld")
    end

    context "unhappy paths" do
      it "rejects missing name" do
        expect {
          post "/api/v1/registration", params: { user: { email_address: "a@x.tld", password: "secretpass" } }
        }.not_to change(User, :count)
        expect(response.status).to eq(422)
        expect(cookies[:session_token]).to be_nil
      end

      it "rejects missing email" do
        post "/api/v1/registration", params: { user: { name: "A", password: "secretpass" } }
        expect(response.status).to eq(422)
        expect(cookies[:session_token]).to be_nil
      end

      it "rejects invalid or taken email" do
        create(:user, email_address: "dup@x.tld")
        post "/api/v1/registration", params: { user: { name: "A", email_address: "dup@x.tld", password: "secretpass" } }
        expect(response.status).to eq(422)
        expect(cookies[:session_token]).to be_nil
      end

      it "rejects short password" do
        post "/api/v1/registration", params: { user: { name: "A", email_address: "a@x.tld", password: "short" } }
        expect(response.status).to eq(422)
        expect(cookies[:session_token]).to be_nil
      end

      it "rejects password confirmation mismatch" do
        post "/api/v1/registration", params: { user: { name: "A", email_address: "a@x.tld", password: "secretpass", password_confirmation: "nope" } }
        expect(response.status).to eq(422)
        expect(cookies[:session_token]).to be_nil
      end

      it "rejects missing user payload" do
        post "/api/v1/registration", params: {}
        expect(response.status).to eq(400).or eq(422) # if params.require(:user) raises, you may map to 400
      end

      it "does not leak validation errors shape" do
        post "/api/v1/registration", params: { user: { name: "", email_address: "", password: "" } }
        expect(response.status).to eq(422)
        expect(json[:error]).to eq("validation_failed")
        expect(json[:messages]).to be_an(Array)
      end
    end
  end
end
