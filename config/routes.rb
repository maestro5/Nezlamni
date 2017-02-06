Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  root 'pages#home'
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  
  resources :users, only: %i(index destroy show edit update)

  resources :accounts do
    member do
      get 'checked'
      get 'visible'
      get 'locked'
    end

    resources :images, only: %i(index new create set_avatar) do
      get 'set_avatar', on: :member
    end

    resources :products, only: %i(new create index)
    resources :articles, only: %i(new create)
    resources :comments, only: %i(create edit update destroy)
  end # accounts

  resources :products, except: %i(new create index) do
    member do
      get 'checked'
      get 'visible'
    end

    resources :images, only: %i(index new create set_avatar) do
      get 'set_avatar', on: :member
    end

    resources :orders, only: %i(new create)
  end # products
  
  get '/products', to: 'pages#products'

  resources :images, only: :destroy

  resources :articles do
    get 'visible', on: :member
  end # articles (news)

  resources :orders, only: %i(index show) do
    get 'delivered', on: :member
  end # orders

end
