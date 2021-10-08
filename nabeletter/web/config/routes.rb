Rails.application.routes.draw do
  root to: redirect("/admin")

  get "/admin", controller: :packs, action: :admin
  get "/signup", controller: :packs, action: :signup
  post "/signups", controller: :signups, action: :signup
  get "/pixel", controller: :analytics, action: :pixel
  get '/s/:short', to: "analytics#short", as: :short

  resources :editions, only: %i[index show]

  resources :analytics, only: :index
  resources :events, only: :index
  resources :articles, only: :index
  resources :permits, only: :index
  resources :translations, only: :create
  resources :pages, only: :show

  namespace :api do
    jsonapi_resources :pages, only: %i[index create update show]
    jsonapi_resources :page_sections, only: %i[index create update show]
    jsonapi_resources :editions, only: %i[index create update show]
    jsonapi_resources :newsletters, only: %i[index show]
    jsonapi_resources :subscriptions, only: %i[index show create update]
    jsonapi_resources :units, only: %i[index create update show]
    jsonapi_resources :users, only: %i[index]
    jsonapi_resources :links, only: %i[index show update]
    resources :sms, only: :create
  end

  # NOTE: https://bit.ly/2UEyLO1
  devise_for :users,
             path: "",
             path_names: { sign_in: "tokens", sign_out: "tokens" },
             controllers: { sessions: "sessions" },
             defaults: { format: :json }

  # static pages
  get "/privacy", to: redirect("privacy.html")

end
