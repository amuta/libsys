require "rails_helper"
RSpec.describe "Copies", type: :request do
  let!(:lib) { create(:user, :librarian) }
  let!(:mem) { create(:user) }
  let!(:book) { create(:book) }

  it "librarian adds a copy to a book" do
    sign_in(lib)
    post "/api/v1/books/#{book.id}/copies", params: { barcode: "B123" }
    expect(response).to have_http_status(:created)
    expect(json[:barcode]).to eq("B123")
  end

  it "member cannot add copy" do
    sign_in(mem)
    post "/api/v1/books/#{book.id}/copies", params: { barcode: "B2" }
    expect(response).to have_http_status(:forbidden)
  end

  it "deletes a copy if no active loan; blocks if active" do
    sign_in(lib)
    copy = book.copies.create!(barcode: "C1")
    delete "/api/v1/copies/#{copy.id}"
    expect(response).to have_http_status(:no_content)

    copy2 = book.copies.create!(barcode: "C2", status: :available)
    # create active loan
    borrower = create(:user)
    Loan::Create.call!(user: borrower, loanable: book)
    delete "/api/v1/copies/#{copy2.id}"
    expect(response).to have_http_status(:conflict)
    expect(json[:error]).to eq("active_loan")
  end
end
