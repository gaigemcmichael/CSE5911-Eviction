Rails.application.routes.draw do
  get "mediator_cases/show"
  get "third_party_mediations/index"
  get "manage_cases/index"
  root "sessions#new"  # Home Page

  # Authentication
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"

  # Dashboard Pages
  get "/dashboard", to: "dashboard#index", as: "dashboard"
  get "dashboard/landlord", to: "dashboard#landlord", as: "landlord_dashboard"
  get "dashboard/tenant", to: "dashboard#tenant", as: "tenant_dashboard"
  get "dashboard/admin", to: "dashboard#admin", as: "admin_dashboard"
  get "dashboard/mediator", to: "dashboard#mediator", as: "mediator_dashboard"

  # User Signup and Account Management
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get "/account", to: "account#show"
  get "/account/edit", to: "account#edit"
  patch "/account", to: "account#update"

  get "messages/tenant_show/:conversation_id", to: "messages#show", as: "tenant_show"
  get "messages/landlord_show/:conversation_id", to: "messages#show", as: "landlord_show"

  # get '/complete_screening', to: 'screenings#complete_screening'

  get "screenings/new/:conversation_id", to: "screenings#new", as: "new_screening"

  # Resources
  resources :messages, only: [ :index, :show, :create, :destroy ] do
    patch :request_mediator, on: :member  # Custom action inside messages
  end


  resources :documents, only: [ :index, :show, :create, :destroy ]
  resources :resources, only: [ :index ]

  # Admin Account Management
  resources :accounts, only: [ :index, :show, :create, :destroy ], as: "admin_accounts"

  # System Data
  resource :system_data, only: [ :show ]

  # Mediations and Related Actions
  resources :mediations, only: [ :new, :create, :edit, :update, :destroy ] do
    post :accept, on: :member
    post :respond, on: :member
  end

  # Allow third party mediator to view cases
  resources :third_party_mediations, only: [ :index ]
  resources :mediator_cases, only: [ :show ]

  resources :screenings, only: [ :new, :create ]

  # Messages related ActionCable
  mount ActionCable.server => "/cable"
end
