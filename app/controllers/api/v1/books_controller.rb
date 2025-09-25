class Api::V1::BooksController < ApplicationController
  def index
    @books = policy_scope(Book).includes(:genre)
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
      @book.author_ids = Array(params.dig(:book, :author_ids))
    end
    render :show, status: :created
  end

  def update
    @book = Book.find(params[:id]); authorize @book
    Book.transaction do
      @book.update!(book_params)
      @book.author_ids = Array(params.dig(:book, :author_ids)) if params.dig(:book, :author_ids)
    end
    head :no_content
  end

  def borrow
    @book = Book.find(params[:id]); authorize @book, :show?
    @loan = Loan::Create.call(user: Current.user, loanable: @book)
    render "api/v1/loans/show", status: :created
  end
end
