Rails.application.routes.draw do
  root 'pages#home'
  devise_for :users
  
  resources :accounts, only: [:index, :show, :edit, :update]  do
    post 'user_publish' => 'accounts#publish'
  end

end
