class Api::V1::GenresController < Api::V1::BaseController
  before_action :authenticate!

  def search
    @genres = Genre.search(params[:q])
    render :search
  end
end
