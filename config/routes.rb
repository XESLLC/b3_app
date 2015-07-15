Rails.application.routes.draw do

  root 'dashboard#index'

  get 'auth/new' => 'auth#new', as: :new_auth
  post 'auth/create' => 'auth#create', as: :create_auth
  delete 'auth/destroy' => 'auth#destroy', as: :destroy_auth
  get 'dashboard/reload_pick_teams' => 'dashboard#reload_pick_teams'
  post 'dashboard/pick_teams' => 'dashboard#pick_teams'
  post 'user_shares/create_bid' => 'user_shares#create_bid'
  post 'ask/update_js' => 'ask#update_js'

  resources :users
  resources :user_shares
  resources :ask
  resources :bid

end
