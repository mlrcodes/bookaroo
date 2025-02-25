Rails.application.routes.draw do
  resources :users do
    resources :books
  end

  resource :registration, only: [:new, :create]

  root "main#index"
end
