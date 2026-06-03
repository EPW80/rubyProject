# frozen_string_literal: true

module AuthHelpers
  # Mints a JWT the same way devise-jwt does on login, so request specs exercise
  # the real Warden authentication path.
  def auth_headers(user)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end
end
