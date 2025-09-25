class Api::V1::CopiesController < Api::V1::BaseController
  before_action :authenticate!

  def destroy
    @copy = Copy.find(params[:id])
    authorize @copy, :destroy?
    return render(json: { error: "active_loan" }, status: :conflict) if @copy.active_loan.present?
    @copy.destroy
    head :no_content
  end
end
