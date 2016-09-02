Rails.application.routes.draw do
  root 'pages#home'
  devise_for :users
  
  resources :accounts, only: [:index, :show, :edit, :update, :destroy]  do
    member do
      get 'checked'
      get 'visible'
      get 'locked'
    end

    resources :images, only: [:index, :new, :create, :set_avatar] do
      get 'set_avatar', on: :member
    end

    resources :products, only: [:new, :create, :index]
  end

  resources :orders, only: [:index, :show] do
    get 'delivered', on: :member
  end

  resources :products, except: [:new, :create, :index] do
    member do
      get 'checked'
      get 'visible'
    end

    resources :images, only: [:index, :new, :create, :set_avatar] do
      get 'set_avatar', on: :member
    end

    resources :orders, only: [:new, :create]
  end
  
  get '/products', to: 'pages#products'
  resources :images, only: [:destroy]
end

