Rails.application.routes.draw do
  root to: redirect("/admin")

  get "/admin", controller: :pages, action: :admin
  get "/signup", controller: :pages, action: :signup
  post "/signups", controller: :signups, action: :signup
  get "/pixel", controller: :analytics, action: :pixel

  resources :analytics, only: :index
  resources :events, only: :index
  resources :articles, only: :index
  resources :permits, only: :index

  jsonapi_resources :newsletters, only: %i[index show]
  jsonapi_resources :editions, only: %i[index create update show]
  jsonapi_resources :subscriptions, only: %i[index show create update]
  jsonapi_resources :users, only: %i[index]

  # NOTE: https://bit.ly/2UEyLO1
  devise_for :users,
             path: "",
             path_names: { sign_in: "tokens", sign_out: "tokens" },
             controllers: { sessions: "sessions" },
             defaults: { format: :json }

  # static pages
  get "/privacy", to: redirect("privacy.html")

end
