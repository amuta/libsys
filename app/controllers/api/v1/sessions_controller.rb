class Api::V1::SessionsController < Api::V1::BaseController
  def create
    user = User.find_by(email_address: params[:email_address])
    if user&.authenticate(params[:password])
      @session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      cookies.encrypted[:session_token] = { value: @session.id, httponly: true, secure: Rails.env.production?, same_site: :strict }
      Current.session = @session
      render :create, status: :created
    else
      head :unauthorized
    end
  end

  def show
    authenticate!
    @user = Current.user
  end

  def destroy
    if Current.session
      Current.session.destroy
      cookies.delete(:session_token)
      Current.session = nil
    end
    head :no_content
  end
end
