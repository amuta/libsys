class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  include Pundit::Authorization
  protect_from_forgery with: :exception
  before_action { response.set_header("X-CSRF-Token", form_authenticity_token) }
  def authenticate! = head :unauthorized unless Current.user
end
