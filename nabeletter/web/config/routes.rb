Rails.application.routes.draw do

  root to: redirect('/admin')

  get '/admin', controller: :pages, action: :admin

  jsonapi_resources :newsletters, only: %i[ index show ]
  jsonapi_resources :editions, only: %i[ index create update show ]
  jsonapi_resources :subscriptions, only: %i[ index show create ]

end
