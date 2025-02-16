Rails.application.routes.draw do
  root "sessions#new"  # Home Page
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"  # This one wont work and I want it to, unsure why
  get "/logout", to: "sessions#destroy"  # This fixes the above one
 
  get "/dashboard", to: "dashboard#index"  # Dashboard Page

  # Signup route ideas - not implemented
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
end