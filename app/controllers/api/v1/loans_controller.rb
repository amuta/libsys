class Api::V1::LoansController < Api::V1::BaseController
  before_action :authenticate!

  def index
    scope = policy_scope(Loan).includes(:user, copy: :loanable).order(created_at: :desc)
    scope = scope.where(user: Current.user) if params[:mine].present?
    @loans = scope
    render :index
  end

  def return
    @loan = Loan.find(params[:id])
    authorize @loan, :return?
    Loan::Return.call!(librarian: Current.user, loan: @loan)
    head :no_content
  end
end
