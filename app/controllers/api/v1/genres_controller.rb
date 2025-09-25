class Api::V1::GenresController < Api::V1::BaseController
  def search
    authenticate!
    return unless Current.user
    @genres = Genre.search(params[:q])
    render :search
  end
end
