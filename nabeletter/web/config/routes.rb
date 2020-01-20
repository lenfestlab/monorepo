Rails.application.routes.draw do
  root to: redirect('/admin')
  get '/admin', controller: :pages, action: :admin

  resources :newsletters, only: %i[ index show ]
  resources :editions, only: %i[ index create update show ]
  resources :subscriptions, only: %i[ index show create ]
end
