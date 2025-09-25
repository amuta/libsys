class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  before_action :set_current_session

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "forbidden" }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end

  rescue_from Loan::Exceptions::NotAvailable do
    render json: { error: "not_available" }, status: :unprocessable_content
  end

  rescue_from Loan::Exceptions::AlreadyBorrowed do
    render json: { error: "already_borrowed" }, status: :conflict
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    error_messages = exception.record.errors.full_messages
    render json: { error: "validation_failed", messages: error_messages }, status: :unprocessable_content
  end

  rescue_from Loan::Exceptions::AlreadyReturned do
    render json: { error: "already_returned" }, status: :conflict
  end

  def authenticate!
    head :unauthorized unless Current.user
  end

  def current_user
    Current.user
  end

  private

  def set_current_session
    sid = cookies.encrypted[:session_token]
    return unless sid
    Current.session = Session.find_by(id: sid)
  end
end
