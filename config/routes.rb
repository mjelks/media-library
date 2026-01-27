Rails.application.routes.draw do
  resources :locations
  resources :users
  resources :media_owners
  get "record_collection", to: "record_collection#index"
  get "record_collection/location/:id", to: "record_collection#show", as: :record_collection_location
  patch "record_collection/location/:id/reorder", to: "record_collection#reorder", as: :record_collection_reorder
  patch "record_collection/location/:location_id/move_to_top/:id", to: "record_collection#move_to_top", as: :record_collection_move_to_top
  patch "record_collection/location/:location_id/move_to_bottom/:id", to: "record_collection#move_to_bottom", as: :record_collection_move_to_bottom
  get "record_collection/location/:id/add", to: "record_collection#add_to_collection", as: :record_collection_add
  get "record_collection/cube/:id", to: "record_collection#cube", as: :record_collection_cube
  resources :media_types
  resources :media_items
  resources :releases
  resources :genres
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  # Discogs search
  resources :discogs, only: %i[index show create]

  # get "homepage/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "test" => "homepage#test"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "homepage#index"

  # :nocov:
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  # :nocov:
end
