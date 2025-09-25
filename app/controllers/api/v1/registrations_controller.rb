class Api::V1::RegistrationsController < Api::V1::BaseController
  def create
    user = User.create!(user_params)
    session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)

    cookies.encrypted[:session_token] = {
      value: session.id, httponly: true, secure: Rails.env.production?, same_site: :strict
    }
    Current.session = session
    @session = session
    render "api/v1/sessions/create", status: :created
  end

  private

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
