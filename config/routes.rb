Rails.application.routes.draw do
  root "services#index"
  resource :session, only: %i[new create destroy]
  resources :registrations, only: %i[new create]
  resources :services
  resources :availability_slots, except: %i[show]
  resources :bookings, only: %i[index new create show] do
    member do
      patch :confirm
      patch :cancel
      patch :complete
    end
  end
  resources :reviews, only: %i[new create]
  resources :notifications, only: :index do
    collection { patch :mark_all_read }
  end
  namespace :admin do
    root "dashboard#index"
    resources :users, only: %i[index update]
    resources :services, only: %i[index update]
    resources :bookings, only: :index
    resources :reviews, only: :index
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
