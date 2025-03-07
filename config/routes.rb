Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "/home", to: "static_pages#home"
    get "/help", to: "static_pages#help"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users do
      member do
        get :following, :followers
      end
    end

    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new edit create update)
    resources :microposts, only: %i(create destroy)
    resources :relationships, only: %i(create destroy)
  end
end
