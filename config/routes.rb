Rails.application.routes.draw do
  root 'projects#index'
  get 'login', to: 'sessions#login'
end
