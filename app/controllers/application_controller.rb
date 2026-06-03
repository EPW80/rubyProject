# frozen_string_literal: true

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pundit::Authorization
  include Pagy::Backend

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  # `authenticate_user!` and `current_user` are provided by Devise; request
  # authentication is stateless via the devise-jwt Warden strategy.

  def forbidden
    render json: { errors: ['Forbidden'] }, status: :forbidden
  end

  def not_found
    render json: { errors: ['Not found'] }, status: :not_found
  end
end
