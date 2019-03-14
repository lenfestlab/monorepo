Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :installations, only: :update
  %i[
    places
    categories
    nabes
    authors
  ].each do |resource_name|
    resources resource_name, only: :index
  end

  # static pages
  get "/privacy", to: redirect("privacy.html")
  get "/tos", to: redirect("tos.html")

  get "/about", to: redirect(
    (ENV["APP_ABOUT_URL"] ||
     "https://medium.com/the-lenfest-local-lab"))

  get "/here", to: redirect(
    (ENV["APP_MARKETING_URL"] ||
     "https://testflight.apple.com/join/vqlIFhxI"))

  get "force_exception" => "application#force_exception"
end
