Rails.application.routes.draw do
  root 'projects#index'

  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'
  get 'auth/:provider/callback', to: 'sessions#create'

  #omniauthログイン用パス（実際にsessions#authアクションは使用しない）
  get 'auth/:id', to: 'sessions#auth', as: :auth

  get 'mypage', to: 'users#edit'
  patch 'mypage', to: 'users#update'
  delete 'mypage', to: 'users#destroy'

  resources :projects
  get 'myprojects', to: 'projects#index'
end
