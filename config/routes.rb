Minutes::Application.routes.draw do
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout

  get '/article' => 'articles#show'

  root to: 'articles#index'
end
