Rails.application.routes.draw do
  root "sessions#new"  # Home Page
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"  # This one wont work and I want it to, unsure why
  get "/logout", to: "sessions#destroy"  # This fixes the above one
 
  get "/dashboard", to: "dashboard#index", as: "dashboard" # Dashboard Page

  # Signup route ideas - not implemented
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get 'dashboard/landlord', to: 'dashboard#landlord', as: 'landlord_dashboard'
  get 'dashboard/tenant', to: 'dashboard#tenant', as: 'tenant_dashboard'
  get 'dashboard/admin', to: 'dashboard#admin', as: 'admin_dashboard'
  get 'dashboard/mediator', to: 'dashboard#mediator', as: 'mediator_dashboard'

  resources :messages, only: [:index, :show, :create, :destroy]
  resources :documents, only: [:index, :show, :create, :destroy]
  resources :resources, only: [:index]
  resources :mediations, only: [:index, :show, :create, :destroy]
  resources :accounts, only: [:index, :show, :create, :destroy], as: "admin_accounts"
  resource :system_data, only: [:show]
  resource :account, only: [:show, :edit, :update]

end