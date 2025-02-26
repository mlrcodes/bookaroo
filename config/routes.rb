Rails.application.routes.draw do
  resources :users do
    resources :books
  end

  resource :registration, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]

  root "home#index"
end
