class Api::V1::BooksController < Api::V1::BaseController
  before_action :authenticate!

  def index
    @books = policy_scope(Book)
              .search(params[:q])
              .includes(:genres, contributions: :agent)
              .order(created_at: :desc)
    render :index
  end

  def show
    @book = Book.find(params[:id]); authorize @book
    render :show
  end

  def create
    @book = Book.new(book_params); authorize @book
    @book = Book::Create.call!(
      attrs: book_params,
      genre_ids: params.dig(:book, :genre_ids),
      author_ids: params.dig(:book, :author_ids)
    )
    render :show, status: :created
  end


  def update
    @book = Book.find(params[:id]); authorize @book
    Book.transaction do
      @book.update!(book_params)
      @book.genre_ids = Array(params.dig(:book, :genre_ids)).map!(&:to_i).uniq
      @book.author_ids = Array(params.dig(:book, :author_ids))
    end
    head :no_content
  end

  def destroy
    @book = Book.find(params[:id]); authorize @book
    @book.destroy!
    head :no_content
  end

  def borrow
    @book = Book.find(params[:id]); authorize @book, :show?
    @loan = Loan::Create.call!(user: Current.user, loanable: @book)
    render "api/v1/loans/show", status: :created
  end

  def copies
    @book = Book.find(params[:id]); authorize @book, :update?
    @copy = @book.copies.create!(barcode: params.require(:barcode))
    render "api/v1/copies/show", status: :created
  end

  private

  def book_params
    params.require(:book).permit(:title, :isbn, :language)
  end
end
