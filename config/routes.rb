require_relative "../lib/authenticated_constraint"

Rails.application.routes.draw do
  # API documentation (requires session authentication)
  constraints(AuthenticatedConstraint.new) do
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end
  # API routes for macOS Widget
  namespace :api do
    namespace :v1 do
      get "me", to: "profile#me"
      get "widget/search", to: "widget#search"
      get "widget/random", to: "widget#random"
      get "widget/now_playing", to: "widget#now_playing"
      get "widget/recently_played", to: "widget#recently_played"
      get "widget/play_history", to: "widget#play_history"
      get "widget/wishlist", to: "widget#wishlist"
      delete "widget/wishlist/:id", to: "widget#wishlist_delete", as: :widget_wishlist_delete
      get "widget/:id", to: "widget#show", as: :widget_show
      post "widget/:id/play", to: "widget#play", as: :widget_play
      patch "widget/:id/done", to: "widget#done", as: :widget_done
      delete "widget/:id", to: "widget#delete", as: :widget_delete
    end
  end

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

  # CD Collection
  get "cd_collection", to: "cd_collection#index"
  get "cd_collection/location/:id", to: "cd_collection#show", as: :cd_collection_location
  patch "cd_collection/location/:id/reorder", to: "cd_collection#reorder", as: :cd_collection_reorder
  patch "cd_collection/location/:location_id/move_to_top/:id", to: "cd_collection#move_to_top", as: :cd_collection_move_to_top
  patch "cd_collection/location/:location_id/move_to_bottom/:id", to: "cd_collection#move_to_bottom", as: :cd_collection_move_to_bottom
  get "cd_collection/location/:id/add", to: "cd_collection#add_to_collection", as: :cd_collection_add
  post "cd_collection/location/:id/insert_gap/:slot", to: "cd_collection#insert_gap", as: :cd_collection_insert_gap
  delete "cd_collection/location/:id/remove_gap/:slot", to: "cd_collection#remove_gap", as: :cd_collection_remove_gap

  # Now Playing
  get "now_playing", to: "now_playing#index"
  get "now_playing/search", to: "now_playing#search"
  get "now_playing/random", to: "now_playing#random", as: :now_playing_random
  post "now_playing/:id/play", to: "now_playing#play", as: :now_playing_play
  post "now_playing/:id/done", to: "now_playing#done", as: :now_playing_done
  delete "now_playing/:id", to: "now_playing#delete", as: :now_playing_delete
  post "now_playing/:id/rate", to: "now_playing#rate", as: :now_playing_rate
  patch "now_playing/:id/notes", to: "now_playing#update_notes", as: :now_playing_update_notes
  post "now_playing/:id/confirm", to: "now_playing#confirm_listening", as: :now_playing_confirm

  # Wishlist
  resources :wishlist, only: %i[index show destroy], controller: "wishlist"

  resources :media_types
  resources :media_items do
    post :clone, on: :member
  end
  resources :releases
  resources :genres
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  # Discogs search
  resources :discogs, only: %i[index show create] do
    post :add_to_wishlist, on: :member
  end

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
