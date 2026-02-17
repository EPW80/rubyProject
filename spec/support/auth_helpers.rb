module AuthHelpers
  def auth_headers(user)
    token = JWT.encode(
      { sub: user.id, exp: 24.hours.from_now.to_i },
      jwt_secret,
      'HS256'
    )
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  private

  def jwt_secret
    ENV.fetch('JWT_SECRET_KEY', 'fallback_test_secret_do_not_use_in_production')
  end
end
