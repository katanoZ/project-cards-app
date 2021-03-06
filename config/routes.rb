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

  resources :projects do
    get 'invite', on: :member

    resources :columns, only: %i[new create edit update destroy] do
      get 'previous', on: :member
      get 'next', on: :member

      resources :cards, only: %i[new create edit update destroy] do
        get 'previous', on: :member
        get 'next', on: :member
      end
    end

    resources :logs, only: %i[index]
  end

  get 'myprojects', to: 'projects#index'

  get 'notifications', to: 'memberships#index'
  resources :memberships, only: %i[create update]
end
