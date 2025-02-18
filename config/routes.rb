Rails.application.routes.draw do
  get "account/show"
  get "account/edit"
  get "account/update"
  get "account/index"
  get "accounts/index"
  get "documents/index"
  get "messages/index"
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

  # User account management
  get '/account', to: 'account#show'
  get '/account/edit', to: 'account#edit'
  patch '/account', to: 'account#update'

  resources :messages, only: [:index, :show, :create, :destroy]
  resources :documents, only: [:index, :show, :create, :destroy]
  resources :resources, only: [:index]
  resources :mediations, only: [:index, :show, :create, :destroy]
  resources :accounts, only: [:index, :show, :create, :destroy], as: "admin_accounts"
  resources :messages, only: [:index]
  resources :documents, only: [:index]
  resource :system_data, only: [:show]
  resources :mediations, only: [:index, :create] do
    post :respond, on: :member
  end
  #resource :account, only: [:show, :edit, :update]
end