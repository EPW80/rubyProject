# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  let(:json_headers) { { 'Content-Type' => 'application/json' } }

  describe 'POST /api/v1/signup' do
    it 'creates a user and dispatches a JWT' do
      expect do
        post '/api/v1/signup',
             params: { user: { email: 'new@example.com', password: 'password123' } }.to_json,
             headers: json_headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.headers['Authorization']).to match(/\ABearer .+/)
      expect(response.parsed_body['message']).to eq('Signed up successfully.')
    end

    it 'returns validation errors for a duplicate email' do
      create(:user, email: 'taken@example.com')

      post '/api/v1/signup',
           params: { user: { email: 'taken@example.com', password: 'password123' } }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end

    it 'returns validation errors for a too-short password' do
      post '/api/v1/signup',
           params: { user: { email: 'short@example.com', password: 'x' } }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
