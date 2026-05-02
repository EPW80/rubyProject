# frozen_string_literal: true

# config/initializers/rack_attack.rb
Rack::Attack.throttle('api/ip', limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api/')
end

Rack::Attack.throttle('api/create/ip', limit: 10, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api/') && req.post?
end

Rack::Attack.throttled_responder = lambda do |_req|
  [429, { 'Content-Type' => 'application/json' },
   [{ errors: ['Rate limit exceeded. Please slow down.'] }.to_json]]
end
