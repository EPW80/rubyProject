# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:json_headers) { { 'Content-Type' => 'application/json' } }
  let!(:user) { create(:user, password: 'password123') }

  describe 'POST /api/v1/login' do
    it 'authenticates and returns a JWT in the Authorization header' do
      post '/api/v1/login',
           params: { user: { email: user.email, password: 'password123' } }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to match(/\ABearer .+/)
      expect(response.parsed_body['message']).to eq('Logged in successfully.')
    end

    it 'rejects invalid credentials' do
      post '/api/v1/login',
           params: { user: { email: user.email, password: 'wrong' } }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['Authorization']).to be_nil
    end
  end

  describe 'DELETE /api/v1/logout' do
    it 'revokes the token so it can no longer authenticate' do
      post '/api/v1/login',
           params: { user: { email: user.email, password: 'password123' } }.to_json,
           headers: json_headers
      token = response.headers['Authorization']
      auth = { 'Authorization' => token }

      # Token works before logout.
      get api_v1_projects_path, headers: auth
      expect(response).to have_http_status(:ok)

      delete '/api/v1/logout', headers: auth
      expect(response).to have_http_status(:ok)

      # Same token is denylisted after logout.
      get api_v1_projects_path, headers: auth
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
