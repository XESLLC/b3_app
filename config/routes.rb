Rails.application.routes.draw do

  root 'dashboard#index'

  get 'auth/new' => 'auth#new', as: :new_auth
  post 'auth/create' => 'auth#create', as: :create_auth
  delete 'auth/destroy' => 'auth#destroy', as: :destroy_auth

  resources :users

end
