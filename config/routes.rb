Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      post "auth/register", to: "auth#register"
      post "auth/refresh", to: "auth#refresh"
      delete "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"
      post "payment_webhooks/hubtel", to: "payment_webhooks#hubtel"
      post "payment_webhooks/zeepay", to: "payment_webhooks#zeepay"

      resources :properties, only: %i[index show create update destroy]
      resources :users, only: %i[index show create update destroy]
      resources :property_memberships, only: %i[index show create update]
      resources :units, only: %i[index show create update destroy] do
        collection { post :bulk_create }
      end
      resources :tenants, only: %i[index show create update destroy]
      resources :leases, only: %i[index show create update destroy]
      resources :rent_installments, only: %i[index show]
      resources :invoices, only: %i[index show create update destroy] do
        resources :invoice_items, only: %i[create]
      end
      resources :invoice_items, only: %i[update destroy]
      resources :payments, only: %i[index show create destroy]
      resources :online_payments, only: %i[index show create] do
        member do
          post :confirm
          post :fail
        end
      end
      resources :payment_allocations, only: %i[index show]
      resources :meter_readings, only: %i[index show create update]
      resources :pump_topups, only: %i[index show create update]
      resources :maintenance_requests, only: %i[index show create update destroy]
      resources :audit_logs, only: %i[index show]
      post "billing/water_invoices", to: "billing#create_water_invoices"
    end
  end
end
