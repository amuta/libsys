class Api::V1::SessionsController < Api::V1::BaseController
  def create
    user = User.find_by(email_address: params[:email_address])
    if user&.authenticate(params[:password])
      @session = user.sessions.create!
      cookies.encrypted[:session_token] = @session.id
      Current.session = @session
      render :create, status: :created
    else
      head :unauthorized
    end
  end

  def show
    authenticate!
    return unless Current.user
    @user = Current.user
    render :show
  end

  def destroy
    if Current.session
      Current.session.destroy
      cookies.delete(:session_token)
    end
    head :no_content
  end
end
