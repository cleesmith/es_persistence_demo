Rails.application.routes.draw do
  resources :sessions
  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"
  resources :password_resets
  resources :users
  resources :home, :only => [:index]
  root to: 'home#index'
end
