Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource  :session, only: [ :create, :destroy, :show ]

      resources :books do
        post   :borrow,  on: :member   # POST /books/:id/borrow  → picks an available copy
        post   :copies,  on: :member   # POST /books/:id/copies  → add a copy
      end

      resources :copies, only: [ :destroy ]         # DELETE /copies/:id
      resources :loans,  only: [ :index ] do
        patch :return, on: :member                # PATCH /loans/:id/return
      end

      get "people/search", to: "people#search"
      get "genres/search", to: "genres#search"
    end
  end
end
