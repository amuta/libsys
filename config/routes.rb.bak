Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :session, only: %i[create show destroy], controller: :sessions
      resource :registration, only: :create, controller: :registrations
      resources :books do
        post :borrow, on: :member
        post :copies, on: :member
      end
      resources :copies, only: :destroy
      resources :loans,  only: %i[index] do
        patch :return, on: :member
      end
      get "people/search", to: "people#search"
      get "genres/search", to: "genres#search"
    end
  end
end
