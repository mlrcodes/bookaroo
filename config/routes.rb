Rails.application.routes.draw do
  resources :users
  resources :books
  root "home#index"
end
