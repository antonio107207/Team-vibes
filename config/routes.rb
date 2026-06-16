Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions"
  }

  root "feed#index"

  resources :hobby_entries, except: [:index] do
    resources :likes,    only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
    resource  :favorite, only: [:create, :destroy]
  end

  resources :profiles, only: [:show, :edit, :update], param: :id do
    resource :follow, only: [:create, :destroy]
  end

  get "favorites",  to: "favorites#index",  as: :favorites
  get "following",  to: "follows#index",    as: :following

  get "categories/:category", to: "categories#show", as: :category

  post "locale", to: "locales#update", as: :locale

  get "link_preview", to: "link_previews#show"

  post "translations", to: "translations#create"

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
