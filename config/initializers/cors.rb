# frozen_string_literal: true

# Cross-Origin Resource Sharing (CORS) for the API.
#
# Allowed origins come from the ALLOWED_ORIGINS env var (comma-separated), e.g.
#   ALLOWED_ORIGINS="https://app.studioflow.com,https://admin.studioflow.com"
#
# When ALLOWED_ORIGINS is unset/empty, no cross-origin requests are permitted —
# a secure default that avoids the previous wildcard (`origins '*'`).
allowed_origins = ENV.fetch('ALLOWED_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)

if allowed_origins.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*allowed_origins)
      resource '*',
               headers: :any,
               methods: %i[get post put patch delete options head],
               # Expose the Authorization header so browser clients can read the
               # JWT that devise-jwt returns on login/signup.
               expose: %w[Authorization]
    end
  end
end
