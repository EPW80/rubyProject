# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

Bundler.require(*Rails.groups)

module Studioflow
  class Application < Rails::Application
    config.load_defaults 8.1
    config.api_only = true
    config.time_zone = 'UTC'
    config.active_record.schema_format = :ruby

    # Devise/Warden need cookies + session middleware for sign_in/sign_out even
    # though request authentication itself is stateless via JWT (devise-jwt).
    config.middleware.use ActionDispatch::Cookies
    config.session_store :cookie_store, key: '_studioflow_session'
    config.middleware.use config.session_store, config.session_options

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post put patch delete options head]
      end
    end
  end
end
