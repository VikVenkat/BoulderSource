Rails.application.routes.draw do
  resources :lists
  resources :builders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'builders/index'

root to: 'builders#index'
end
