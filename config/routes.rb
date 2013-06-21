Minutes::Application.routes.draw do
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/success' => 'services#success', via: %i(get post), as: :auth_success
  match '/auth/failure' => 'services#failure', via: %i(get post), as: :auth_failure

  get '/article' => 'articles#show'
end
