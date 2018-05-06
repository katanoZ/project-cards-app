Rails.application.routes.draw do
  root 'projects#index'

  get 'login', to: 'sessions#new'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  get 'mypage', to: 'users#edit'
  patch 'mypage', to: 'users#update'
  delete 'mypage', to: 'users#destroy'

  resources :projects, only: %i[index new create]
  get 'myprojects', to: 'projects#index'
end
