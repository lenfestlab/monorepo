Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :places, only: :index

  # NOTE: deprecated
  resources :posts, only: :index

  get "force_exception" => "application#force_exception"
end
