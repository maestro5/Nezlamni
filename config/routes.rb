Rails.application.routes.draw do
  devise_for :users
  resources :accounts, only: [:index, :show, :edit, :update]

  root 'pages#home'

end
