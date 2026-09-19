require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    # Session cookies for SPA auth (CORS + credentials)
    config.session_store :cookie_store, key: "_acme_salary_session", same_site: :lax
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_acme_salary_session", same_site: :lax
  end
end
