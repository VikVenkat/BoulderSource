Rails.application.routes.draw do
  resources :lists
  resources :builders do
    collection { post :import}
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'builders/index'

  get '/scrape', to:'lists#scrape_next_list'

root to: 'builders#index'
end
