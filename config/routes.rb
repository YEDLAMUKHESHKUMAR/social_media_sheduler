Rails.application.routes.draw do
  root "posts#index"
  
  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/profile", to: "users#show"
  
  # OAuth routes
  get "/auth/:provider/callback", to: "sessions#omniauth"
  
  # Posts routes
  get "/dashboard", to: "posts#index"
  resources :posts
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

