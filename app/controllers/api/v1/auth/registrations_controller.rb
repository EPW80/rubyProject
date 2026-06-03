# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Signup (POST /api/v1/signup). On success devise-jwt dispatches a token
      # in the Authorization header so the new user is immediately authenticated.
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              data: UserSerializer.new(resource).serializable_hash,
              message: 'Signed up successfully.'
            }, status: :created
          else
            render json: { errors: resource.errors.full_messages },
                   status: :unprocessable_content
          end
        end
      end
    end
  end
end
