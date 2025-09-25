Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :session, only: [ :create, :destroy, :show ]
    end
  end
end
