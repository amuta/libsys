class Api::V1::PeopleController < Api::V1::BaseController
  def search
    authenticate!
    return unless Current.user
    @people = Person.search(params[:q])
    render :search
  end
end
