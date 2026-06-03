# frozen_string_literal: true

# Tracks revoked JWTs (by jti) so logged-out / invalidated tokens are rejected.
# Used by devise-jwt via the User model's jwt_revocation_strategy.
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end
