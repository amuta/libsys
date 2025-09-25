require "rails_helper"
RSpec.describe "Loans", type: :request do
  let!(:lib) { create(:user, :librarian) }
  let!(:mem) { create(:user) }
  let!(:book) { create(:book) }

  before { book.copies.create!(barcode: "BC1") }

  it "member borrows a book" do
    sign_in(mem)
    post "/api/v1/books/#{book.id}/borrow"
    expect(response).to have_http_status(:created)
    expect(json[:title]).to eq(book.title)
  end

  it "member cannot borrow when no copies available" do
    sign_in(mem)
    post "/api/v1/books/#{book.id}/borrow"
    expect(response).to have_http_status(:created)
    post "/api/v1/books/#{book.id}/borrow"
    expect(response).to have_http_status(:unprocessable_content)
    expect(json[:error]).to eq("not_available")
  end

  it "member cannot borrow same book twice when another copy exists" do
    # Prepare two copies to ensure the rule is API-level, not inventory-level
    book.copies.create!(barcode: "BC2")
    sign_in(mem)
    post "/api/v1/books/#{book.id}/borrow"
    expect(response).to have_http_status(:created)
    post "/api/v1/books/#{book.id}/borrow"
    expect(response.status).to be_between(409, 422).inclusive
  end

  it "lists my loans; librarian sees all" do
    sign_in(mem)
    post "/api/v1/books/#{book.id}/borrow"
    get "/api/v1/loans"
    expect(response).to have_http_status(:ok)
    expect(json.size).to eq(1)

    sign_in(lib)
    get "/api/v1/loans"
    expect(json.size).to be >= 1
  end

  it "librarian returns a loan; member forbidden" do
    sign_in(mem)
    post "/api/v1/books/#{book.id}/borrow"
    loan_id = json[:id]

    # member forbidden
    patch "/api/v1/loans/#{loan_id}/return"
    expect(response).to have_http_status(:forbidden)

    # librarian can
    sign_in(lib)
    patch "/api/v1/loans/#{loan_id}/return"
    expect(response).to have_http_status(:no_content)
  end
end
