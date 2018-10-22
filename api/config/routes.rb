Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :places, only: :index

  # NOTE: deprecated
  resources :posts, only: :index

  # static pages
  get "/privacy", to: redirect("privacy.html")
  get "/tos", to: redirect("tos.html")
  get "/about", to: redirect("https://medium.com/the-lenfest-local-lab")

  get "force_exception" => "application#force_exception"
end
