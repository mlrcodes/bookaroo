Rails.application.routes.draw do
  resources :users do
    resources :books
  end
  root "home#index"
end
