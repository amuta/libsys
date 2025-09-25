class Api::V1::PeopleController < Api::V1::BaseController
  before_action :authenticate!

  def search
    @people = Person.search(params[:q])
    render :search
  end
end
