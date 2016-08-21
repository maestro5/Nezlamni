Rails.application.routes.draw do
  root 'pages#home'
  devise_for :users
  
  resources :accounts, only: [:index, :show, :edit, :update, :destroy]  do
    member do
      get 'checked'
      get 'locked'
    end
    resources :products, only: [:new, :create]
  end

  resources :products, except: [:new, :create] do
    get 'checked', on: :member
  end
  
end
