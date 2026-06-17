# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.10'

gem 'bootsnap', require: false
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'rack-cors'
gem 'rails', '~> 8.0'

# Auth
gem 'devise', '~> 5.0'
gem 'devise-jwt', '~> 0.13'

# Authorization
gem 'pundit', '~> 2.4'

# Serialization
gem 'jsonapi-serializer', '~> 2.2'

# Pagination
gem 'pagy', '~> 9.3'

# Soft deletes
gem 'discard', '~> 1.4'

# Rate limiting
gem 'rack-attack', '~> 6.7'

# Deployment: containerized HTTP/2 proxy (Thruster) and zero-downtime deploys (Kamal)
gem 'kamal', '~> 2.4', require: false
gem 'thruster', '~> 0.1', require: false

group :development, :test do
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'rspec-rails', '~> 6.1'
  gem 'shoulda-matchers', '~> 8.0'
end

group :test do
  gem 'simplecov', '~> 0.22', require: false
end

group :development do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end
