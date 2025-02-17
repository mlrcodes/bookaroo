Rails.application.routes.draw do
  resources :books
  resources :users
  root "home#index"
end
