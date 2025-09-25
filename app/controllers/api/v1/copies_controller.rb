class Api::V1::CopiesController < ApplicationController
  def destroy
    @copy = Copy.find(params[:id])
    authorize @copy.loanable, :update?
    return render(json: { error: "active_loan" }, status: :conflict) if @copy.active_loan.present?
    @copy.destroy
    head :no_content
  end

  # books_controller.rb
  def copies
    @book = Book.find(params[:id]); authorize @book, :update?
    @copy = @book.copies.create!(barcode: params.require(:barcode))
    render "api/v1/copies/show", status: :created
  end
end
