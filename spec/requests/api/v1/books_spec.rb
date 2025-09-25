require "rails_helper"

RSpec.describe "Books", type: :request do
  let!(:lib) { create(:user, :librarian) }
  let!(:mem) { create(:user) }
  let!(:g1) { create(:genre, name: "Software") }
  let!(:g2) { create(:genre, name: "Architecture") }
  let!(:a1) { create(:person, name: "Martin Fowler") }
  let!(:book) { create(:book, title: "Refactoring", isbn: "9780134757599") }

  before { create(:book_genre, book:, genre: g1) }

  it "indexes and filters by q" do
    sign_in(mem)
    get "/api/v1/books", params: { q: "refac" }
    expect(response).to have_http_status(:ok)
    expect(json.first[:title]).to eq("Refactoring")
  end

  it "shows a book with authors and genres" do
    create(:contribution, catalogable: book, agent: a1, role: :author)
    sign_in(mem)
    get "/api/v1/books/#{book.id}"
    expect(response).to have_http_status(:ok)
    expect(json[:title]).to eq(book.title)
    expect(json[:authors].map { _1[:name] }).to include("Martin Fowler")
    expect(json[:genres].map { _1[:id] }).to include(g1.id)
  end

  it "forbids member create" do
    sign_in(mem)
    post "/api/v1/books", params: { book: { title: "New", isbn: "9780132350884", genre_ids: [ g1.id ] } }

    expect(response).to have_http_status(:forbidden)
  end

  it "librarian creates with authors and genres[]" do
    sign_in(lib)
    post "/api/v1/books", params: {
      book: { title: "New", isbn: "9780132350884", language: "en",
              author_ids: [ a1.id ], genre_ids: [ g1.id, g2.id ] }
    }
    expect(response).to have_http_status(:created)
    expect(json[:authors].map { _1[:id] }).to contain_exactly(a1.id)
    expect(json[:genres].map { _1[:id] }).to match_array([ g1.id, g2.id ])
  end

  it "librarian updates title, authors, and genres[]" do
    sign_in(lib)
    patch "/api/v1/books/#{book.id}", params: { book: { title: "Refactoring 2e",
                                                        author_ids: [ a1.id ], genre_ids: [ g2.id ] } }
    expect(response).to have_http_status(:no_content)

    get "/api/v1/books/#{book.id}"
    expect(json[:title]).to eq("Refactoring 2e")
    expect(json[:authors].map { _1[:id] }).to eq([ a1.id ])
    expect(json[:genres].map { _1[:id] }).to eq([ g2.id ])
  end

  it "librarian deletes; member cannot" do
    sign_in(mem)
    delete "/api/v1/books/#{book.id}"
    expect(response).to have_http_status(:forbidden)
    sign_in(lib)
    delete "/api/v1/books/#{book.id}"
    expect(response).to have_http_status(:no_content)
  end
end
