Rails.application.routes.draw do
  root to: redirect("/admin")

  get "/admin", controller: :pages, action: :admin
  resources :analytics, only: :index
  resources :events, only: :index
  resources :articles, only: :index
  resources :permits, only: :index

  jsonapi_resources :newsletters, only: %i[index show]
  jsonapi_resources :editions, only: %i[index create update show]
  jsonapi_resources :subscriptions, only: %i[index show create]
  jsonapi_resources :users, only: %i[index]

  # NOTE: https://bit.ly/2UEyLO1
  devise_for :users,
             path: "",
             path_names: { sign_in: "tokens", sign_out: "tokens" },
             controllers: { sessions: "sessions" },
             defaults: { format: :json }
end
