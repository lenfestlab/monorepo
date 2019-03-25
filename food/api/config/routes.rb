Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :users, only: :update

  # TODO: deprecate
  resources :installations,
    only: :update,
    controller: :users

  %i[
    places
    categories
    nabes
    authors
  ].each do |resource_name|
    resources resource_name, only: :index
  end

  resources :bookmarks, only: %i[ create index ]
  delete '/bookmarks(/:id)', controller: :bookmarks, action: :destroy

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
