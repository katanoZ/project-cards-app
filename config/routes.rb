Rails.application.routes.draw do
  root 'projects#index'

  get 'login', to: 'sessions#new'
  get 'auth/:provider/callback', to: 'sessions#create'

  get 'mypage', to: 'users#edit'
  resources :users, only: [:update]
end
