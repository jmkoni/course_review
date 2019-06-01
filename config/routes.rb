# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[index new create update destroy] do
    put '/promote', to: 'users#promote'
    put '/demote', to: 'users#demote'
  end
  devise_for :users, path: ''
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#home'
end
