# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Login (POST /api/v1/login) and logout (DELETE /api/v1/logout).
      # devise-jwt dispatches a token in the Authorization header on login and
      # revokes it (denylist) on logout.
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          render json: {
            data: UserSerializer.new(resource).serializable_hash,
            message: 'Logged in successfully.'
          }, status: :ok
        end

        # The token is denylisted by devise-jwt's revocation middleware on the
        # way out, so logout is idempotent and always reports success.
        # Devise 5 passes non_navigational_status:, which we accept and ignore.
        def respond_to_on_destroy(**)
          render json: { message: 'Logged out successfully.' }, status: :ok
        end
      end
    end
  end
end
