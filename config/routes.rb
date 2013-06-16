Minutes::Application.routes.draw do
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/:service/token' => 'services#token', via: %i(get post)
  match '/auth/:service/access_token' => 'services#access_token', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout

  get '/article' => 'articles#show'

  root to: 'articles#show'
end
