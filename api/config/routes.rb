Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :places, only: :index

  # static pages
  get "/privacy", to: redirect("privacy.html")
  get "/tos", to: redirect("tos.html")

  get "/about", to: redirect(
    (ENV["APP_ABOUT_URL"] ||
     "https://medium.com/the-lenfest-local-lab"))

  get "force_exception" => "application#force_exception"
end
