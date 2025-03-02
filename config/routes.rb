Rails.application.routes.draw do
  resources :users do
    resources :books
  end

  resource :registration, only: [:new, :create]
  resource :session, only: [:new, :create, :destroy]
  resource :password, only: [:edit, :update]
  resource :password_reset, only: [:new, :create, :edit, :update]

  root "home#index"
end
