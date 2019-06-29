# typed: strict
# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#home'

  get '/privacy', to: 'application#privacy'
  resources :schools do
    resources :departments do
      resources :courses do
        resources :reviews
      end
    end
  end

  resources :users, only: %i[index] do
    put '/promote', to: 'users#promote'
    put '/demote', to: 'users#demote'
    put '/deactivate', to: 'users#deactivate'
    put '/reactivate', to: 'users#reactivate'
  end
  devise_for :users, path: ''
end

# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#              user_promote PUT    /users/:user_id/promote(.:format)                                                        users#promote
#               user_demote PUT    /users/:user_id/demote(.:format)                                                         users#demote
#                     users GET    /users(.:format)                                                                         users#index
#                           POST   /users(.:format)                                                                         users#create
#                  new_user GET    /users/new(.:format)                                                                     users#new
#                      user PATCH  /users/:id(.:format)                                                                     users#update
#                           PUT    /users/:id(.:format)                                                                     users#update
#                           DELETE /users/:id(.:format)                                                                     users#destroy
#          new_user_session GET    /sign_in(.:format)                                                                       devise/sessions#new
#              user_session POST   /sign_in(.:format)                                                                       devise/sessions#create
#      destroy_user_session DELETE /sign_out(.:format)                                                                      devise/sessions#destroy
#         new_user_password GET    /password/new(.:format)                                                                  devise/passwords#new
#        edit_user_password GET    /password/edit(.:format)                                                                 devise/passwords#edit
#             user_password PATCH  /password(.:format)                                                                      devise/passwords#update
#                           PUT    /password(.:format)                                                                      devise/passwords#update
#                           POST   /password(.:format)                                                                      devise/passwords#create
#  cancel_user_registration GET    /cancel(.:format)                                                                        devise/registrations#cancel
#     new_user_registration GET    /sign_up(.:format)                                                                       devise/registrations#new
#    edit_user_registration GET    /edit(.:format)                                                                          devise/registrations#edit
#         user_registration PATCH  /                                                                                        devise/registrations#update
#                           PUT    /                                                                                        devise/registrations#update
#                           DELETE /                                                                                        devise/registrations#destroy
#                           POST   /                                                                                        devise/registrations#create
#                      root GET    /                                                                                        application#home
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
