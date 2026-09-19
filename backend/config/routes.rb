Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "auth/login",  to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      get    "auth/me",     to: "auth#me"

      resources :employees do
        resources :salaries, only: %i[index create]
      end

      get "stats/overview", to: "stats#overview"

      post "imports/employees", to: "imports#employees"
      get  "exports/employees", to: "exports#employees", defaults: { format: :csv }
    end
  end
end
