class Api::V1::BooksController < Api::V1::BaseController
  before_action :authenticate!

  def index
    @books = policy_scope(Book).includes(:genres)
            .where("LOWER(title) LIKE ?", "%#{params[:q].to_s.downcase}%")
            .order(created_at: :desc)
    render :index
  end

  def show
    @book = Book.find(params[:id]); authorize @book
    render :show
  end

  def create
    authorize Book
    Book.transaction do
      @book = Book.create!(book_params)
      @book.genre_ids = Array(params.dig(:book, :genre_ids)).map!(&:to_i).uniq
      @book.author_ids = Array(params.dig(:book, :author_ids))
    end
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
    @loan = Loan::Create.call(user: Current.user, loanable: @book)
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
