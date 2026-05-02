# frozen_string_literal: true

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split&.last
    return unauthorized unless token

    payload = JWT.decode(token, jwt_secret, true, algorithm: 'HS256').first
    @current_user = User.find(payload['sub'])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    unauthorized
  end

  attr_reader :current_user

  def jwt_secret
    ENV.fetch('JWT_SECRET_KEY')
  end

  def forbidden
    render json: { errors: ['Forbidden'] }, status: :forbidden
  end

  def not_found
    render json: { errors: ['Not found'] }, status: :not_found
  end

  def unauthorized
    render json: { errors: ['Unauthorized'] }, status: :unauthorized
  end
end
