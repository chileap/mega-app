# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  draw :turbo

  # Jumpstart views
  if Rails.env.development? || Rails.env.test?
    mount Jumpstart::Engine, at: "/jumpstart"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Administrate
  authenticated :user, lambda { |u| u.admin? } do
    namespace :admin do
      resources :grocery_categories
      resources :groceries
      resources :meal_templates do
        resources :ingredient_templates, only: [:new, :create, :edit, :update, :destroy]
        resources :instruction_template_steps, only: [:new, :create, :edit, :update, :destroy]
      end

      resources :coupons do
        collection do
          post :import
        end
      end

      resources :announcements
      resources :users do
        resource :impersonate, module: :user
      end
      namespace :user do
        resources :connected_accounts, only: [:index, :show]
      end
      resources :workspaces
      resources :workspace_users
      resources :webhooks, only: [:index, :show]
      resources :plans
      namespace :pay do
        resources :customers
        resources :charges
        resources :payment_methods
        resources :subscriptions
      end

      if defined?(Sidekiq)
        require "sidekiq/web"
        require "sidekiq/cron/web"
        mount Sidekiq::Web => "/sidekiq"
      end

      root to: "dashboard#show"
    end
  end

  # API routes
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :auth
      resource :me, controller: :me
      resource :password
      resources :workspaces
      resources :users
      resources :notification_tokens, only: :create
    end
  end

  # User account
  devise_for :users,
    controllers: {
      omniauth_callbacks: "users/omniauth_callbacks",
      registrations: "users/registrations",
      sessions: "users/sessions"
    }
  devise_scope :user do
    get "session/otp", to: "sessions#otp"
  end

  resources :announcements, only: [:index, :show]
  resources :api_tokens
  resources :workspaces do
    member do
      patch :switch
    end

    resource :transfer, module: :workspaces
    resources :workspace_users, path: :members
    resources :workspace_invitations, path: :invitations, module: :workspaces
  end
  resources :workspace_invitations

  # Calendar Events
  resources :events do
    collection do
      post :sync_calendar
    end
  end

  # Payments
  resource :billing_address
  namespace :payment_methods do
    resource :stripe, controller: :stripe, only: [:show]
  end
  resources :payment_methods
  namespace :subscriptions do
    resource :billing_address
    namespace :stripe do
      resource :trial, only: [:show]
    end
  end
  resources :subscriptions do
    resource :cancel, module: :subscriptions
    resource :pause, module: :subscriptions
    resource :resume, module: :subscriptions
    resource :upcoming, module: :subscriptions

    collection do
      patch :billing_settings
    end

    scope module: :subscriptions do
      resource :stripe, controller: :stripe, only: [:show]
    end
  end
  resources :charges do
    member do
      get :invoice
    end
  end

  resources :agreements, module: :users
  namespace :account do
    resource :password
  end
  resources :notifications, only: [:index, :show]
  namespace :users do
    resources :mentions, only: [:index]
  end
  namespace :user, module: :users do
    resource :two_factor, controller: :two_factor do
      get :backup_codes
      get :verify
    end
    resources :connected_accounts
    resource :preferences, only: [:show, :update, :edit]
  end

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  namespace :webhooks do
    namespace :calendar do
      resources :google_callbacks, only: [:create]
      resources :outlook_callbacks, only: [:create]
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  post :sudo, to: "users/sudo#create"

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  get "/groceries_search", to: "groceries#search", as: :search_groceries

  authenticated :user do
    root to: "dashboard#show", as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
    resources :events do
      member do
        get :destroy_modal
        delete :destroy_recurring
      end
    end
    resources :tasks do
      member do
        get :edit_popover
      end
    end
    resources :lists
    resources :habits do
      member do
        put :undo_completed
      end

      resources :goal_trackers do
        collection do
          post :toggle
        end
      end
    end
    resources :goals do
      member do
        put :completed
        put :uncompleted
      end
    end
    resources :contacts
    resources :contact_groups
    resources :calendars, only: [:index, :new, :create]
    resources :meal_templates, only: [:show] do
      member do
        post :add_to_favorite
        post :remove_from_favorite
      end

      collection do
        get :search
        get :autocomplete
      end
    end
    resources :meals do
      collection do
        get :load_templates
        post :create_from_template
      end
      resources :ingredients
    end
    resources :coupons, only: [:index, :show]
    resources :groceries do
      collection do
        get :find_by_barcode
      end
    end

    resource :timeboxing, only: [:show, :destroy] do
      member do
        put :transfer_items
        put :transfer_notes
        delete :destroy_items
      end
    end

    resources :timeboxings, only: [:create, :update]

    resources :timeboxing_items do
      member do
        put :transfer_to_next_day
        patch :transfer_to_next_day
        put :undo_schedule
      end
    end
  end

  # Public marketing homepage
  root to: "static#index"
end
