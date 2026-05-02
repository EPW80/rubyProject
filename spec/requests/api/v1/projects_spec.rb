# frozen_string_literal: true

# spec/requests/api/v1/projects_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Projects', type: :request do
  let(:user)    { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/projects' do
    let!(:active_projects) { create_list(:project, 3, owner: user, status: 'active') }
    let!(:other_project)   { create(:project, status: 'archived') }

    it 'returns all visible projects' do
      get api_v1_projects_path, headers: headers
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['data']).to be_an(Array)
    end

    it 'filters by status' do
      get api_v1_projects_path, params: { status: 'active' }, headers: headers
      json = response.parsed_body
      expect(json['data'].pluck('attributes').pluck('status')).to all(eq('active'))
    end

    it 'paginates results' do
      create_list(:project, 30, owner: user)
      get api_v1_projects_path, params: { per_page: 10 }, headers: headers
      json = response.parsed_body
      expect(json['data'].length).to be <= 10
      expect(json['meta']['total']).to be > 10
    end

    it 'filters by search query' do
      create(:project, name: 'Brand Refresh', owner: user)
      get api_v1_projects_path, params: { q: 'brand' }, headers: headers
      json = response.parsed_body
      expect(json['data'].first.dig('attributes', 'name')).to match(/brand/i)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          name: 'New Silicon Valley Campaign',
          client: 'TechVenture Inc.',
          status: 'active',
          category: 'Web App',
          deadline: 2.months.from_now.to_date,
          tag_list: %w[React Rails TypeScript]
        }
      }
    end

    it 'creates a project successfully' do
      expect do
        post api_v1_projects_path, params: valid_params.to_json, headers: headers
      end.to change(Project, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json.dig('data', 'attributes', 'name')).to eq('New Silicon Valley Campaign')
    end

    it 'returns errors for invalid data' do
      post api_v1_projects_path,
           params: { project: { name: '', client: '' } }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = response.parsed_body
      expect(json['errors']).to include(match(/Name/), match(/Client/))
    end
  end

  describe 'PATCH /api/v1/projects/:id/update_status' do
    let(:project) { create(:project, owner: user, status: 'active') }

    it 'updates project status' do
      patch update_status_api_v1_project_path(project),
            params: { status: 'review' }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(project.reload.status).to eq('review')
    end

    it 'rejects invalid status' do
      patch update_status_api_v1_project_path(project),
            params: { status: 'nonexistent' }.to_json,
            headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'recalculates progress when recalculate param is present' do
      create_list(:milestone, 2, project: project, completed: true)
      create(:milestone, project: project, completed: false)
      patch update_status_api_v1_project_path(project),
            params: { status: 'review', recalculate: true }.to_json,
            headers: headers
      expect(response).to have_http_status(:ok)
      expect(project.reload.progress).to eq(67)
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, owner: user) }

    it 'soft-deletes the project (discards, does not hard-delete)' do
      expect do
        delete api_v1_project_path(project), headers: headers
      end.not_to change(Project.with_discarded, :count)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['deleted']).to be(true)
      expect(project.reload.discarded_at).not_to be_nil
    end

    it 'excludes soft-deleted projects from the default scope' do
      delete api_v1_project_path(project), headers: headers
      expect(Project.find_by(id: project.id)).to be_nil
    end

    it 'returns 403 for a project not owned by user' do
      other = create(:project)
      delete api_v1_project_path(other), headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/projects/:id/activity' do
    let(:project) { create(:project, owner: user) }

    before { create_list(:activity_log, 30, project: project, user: user) }

    it 'returns paginated activity logs' do
      get activity_api_v1_project_path(project), headers: headers
      json = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(json['data'].length).to be <= 25
      expect(json['meta']).to include('total', 'page', 'per_page', 'pages')
    end

    it 'returns the second page when requested' do
      create_list(:activity_log, 10, project: project, user: user)
      get activity_api_v1_project_path(project), params: { page: 2 }, headers: headers
      json = response.parsed_body
      expect(json['meta']['page']).to eq(2)
    end
  end
end
