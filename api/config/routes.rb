Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :posts, only: :index

  get "force_exception" => "application#force_exception"
end
