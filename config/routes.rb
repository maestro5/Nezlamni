Rails.application.routes.draw do
  root 'pages#home'
  devise_for :users
  
  resources :accounts, only: [:index, :show, :edit, :update, :destroy]  do
    member do
      get 'checked'
      get 'visible'
      get 'locked'
    end
    resources :products, only: [:new, :create]
  end

  resources :orders, only: [:index, :show] do
    get 'delivered', on: :member
  end

  resources :products, except: [:new, :create] do
    member do
      get 'checked'
      get 'visible'
    end
    resources :orders, only: [:new, :create]
  end
  
end
