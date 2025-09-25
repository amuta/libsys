class Api::V1::LoansController < ApplicationController
  def index
    @loans = policy_scope(Loan).includes(copy: :loanable).order(created_at: :desc)
    render :index
  end

  def return
    @loan = Loan.find(params[:id])
    Loan::Return.call(librarian: Current.user, loan: @loan)
    head :no_content
  end
end
