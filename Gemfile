# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.10'

gem 'bootsnap', require: false
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'rack-cors'
gem 'rails', '~> 7.2'

# Auth
gem 'devise', '~> 4.9'
gem 'jwt', '~> 2.8'

# Authorization
gem 'pundit', '~> 2.4'

# Serialization
gem 'jsonapi-serializer', '~> 2.2'

# Pagination
gem 'will_paginate', '~> 4.0'

# Soft deletes
gem 'discard', '~> 1.4'

# Rate limiting
gem 'rack-attack', '~> 6.7'

group :development, :test do
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'rspec-rails', '~> 6.1'
  gem 'shoulda-matchers', '~> 6.0'
end

group :development do
  gem 'rubocop-rails', require: false
end
