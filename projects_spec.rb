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
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end

    it 'filters by status' do
      get api_v1_projects_path, params: { status: 'active' }, headers: headers
      json = JSON.parse(response.body)
      expect(json['data'].pluck('attributes').map { |a| a['status'] }).to all(eq('active'))
    end

    it 'paginates results' do
      create_list(:project, 30, owner: user)
      get api_v1_projects_path, params: { per_page: 10 }, headers: headers
      json = JSON.parse(response.body)
      expect(json['data'].length).to be <= 10
      expect(json['meta']['total']).to be > 10
    end

    it 'filters by search query' do
      create(:project, name: 'Brand Refresh', owner: user)
      get api_v1_projects_path, params: { q: 'brand' }, headers: headers
      json = JSON.parse(response.body)
      expect(json['data'].first.dig('attributes', 'name')).to match(/brand/i)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          name:     'New Silicon Valley Campaign',
          client:   'TechVenture Inc.',
          status:   'active',
          category: 'Web App',
          deadline: 2.months.from_now.to_date,
          tag_list: %w[React Rails TypeScript]
        }
      }
    end

    it 'creates a project successfully' do
      expect {
        post api_v1_projects_path, params: valid_params, headers: headers
      }.to change(Project, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'attributes', 'name')).to eq('New Silicon Valley Campaign')
    end

    it 'returns errors for invalid data' do
      post api_v1_projects_path,
           params: { project: { name: '', client: '' } },
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include(match(/Name/), match(/Client/))
    end
  end

  describe 'PATCH /api/v1/projects/:id/update_status' do
    let(:project) { create(:project, owner: user, status: 'active') }

    it 'updates project status' do
      patch update_status_api_v1_project_path(project),
            params: { status: 'review' },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(project.reload.status).to eq('review')
    end

    it 'rejects invalid status' do
      patch update_status_api_v1_project_path(project),
            params: { status: 'nonexistent' },
            headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, owner: user) }

    it 'soft-deletes the project (discards, does not hard-delete)' do
      expect {
        delete api_v1_project_path(project), headers: headers
      }.not_to change(Project.with_discarded, :count)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['deleted']).to be(true)
      expect(project.reload.discarded_at).not_to be_nil
    end

    it 'excludes soft-deleted projects from the default scope' do
      delete api_v1_project_path(project), headers: headers
      expect(Project.find_by(id: project.id)).to be_nil
    end

    it 'returns 404 for a project not owned by user' do
      other = create(:project)
      delete api_v1_project_path(other), headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/projects/:id/activity' do
    let(:project) { create(:project, owner: user) }

    before { create_list(:activity_log, 30, project: project) }

    it 'returns paginated activity logs' do
      get activity_api_v1_project_path(project), headers: headers
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['data'].length).to be <= 25
      expect(json['meta']).to include('total', 'page', 'per_page', 'pages')
    end

    it 'returns the second page when requested' do
      create_list(:activity_log, 10, project: project) # total now > 25
      get activity_api_v1_project_path(project), params: { page: 2 }, headers: headers
      json = JSON.parse(response.body)
      expect(json['meta']['page']).to eq(2)
    end
  end

  describe 'PATCH /api/v1/projects/:id/update_status with recalculate' do
    let(:project) { create(:project, owner: user, status: 'active') }

    it 'recalculates progress when recalculate param is present' do
      create_list(:milestone, 2, project: project, completed: true)
      create(:milestone, project: project, completed: false)
      patch update_status_api_v1_project_path(project),
            params: { status: 'review', recalculate: true },
            headers: headers
      expect(response).to have_http_status(:ok)
      expect(project.reload.progress).to eq(67)
    end
  end
end


# spec/models/project_spec.rb (continued)
RSpec.describe Project, type: :model do
  describe 'tag_list validation' do
    it 'is valid with 20 or fewer tags' do
      project = build(:project, tag_list: Array.new(20) { |i| "tag#{i}" })
      expect(project).to be_valid
    end

    it 'is invalid with more than 20 tags' do
      project = build(:project, tag_list: Array.new(21) { |i| "tag#{i}" })
      expect(project).not_to be_valid
      expect(project.errors[:tag_list]).to include('cannot exceed 20 tags')
    end

    it 'is invalid when any tag exceeds 50 characters' do
      project = build(:project, tag_list: ['a' * 51])
      expect(project).not_to be_valid
      expect(project.errors[:tag_list]).to include('each tag must be under 50 characters')
    end
  end

  describe 'soft delete' do
    let(:project) { create(:project) }

    it 'is excluded from the default scope after discard' do
      project.discard!
      expect(Project.find_by(id: project.id)).to be_nil
    end

    it 'is recoverable via with_discarded' do
      project.discard!
      expect(Project.with_discarded.find(project.id)).to eq(project)
    end
  end
end


# spec/models/project_spec.rb
require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { build(:project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:client) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[backlog active review on_hold completed archived]) }
    it { is_expected.to validate_numericality_of(:progress).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to have_many(:milestones).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:project_memberships) }
  end

  describe '#recalculate_progress!' do
    let(:project) { create(:project) }

    it 'sets progress to 0 with no milestones' do
      project.recalculate_progress!
      expect(project.reload.progress).to eq(0)
    end

    it 'calculates correct percentage from milestones' do
      create_list(:milestone, 3, project: project, completed: true)
      create_list(:milestone, 1, project: project, completed: false)
      project.recalculate_progress!
      expect(project.reload.progress).to eq(75)
    end
  end

  describe '#overdue?' do
    it 'returns true when deadline has passed and not completed' do
      project = build(:project, deadline: 1.week.ago, status: 'active')
      expect(project.overdue?).to be(true)
    end

    it 'returns false when completed' do
      project = build(:project, deadline: 1.week.ago, status: 'completed')
      expect(project.overdue?).to be(false)
    end
  end

  describe 'scopes' do
    before do
      create(:project, status: 'active')
      create(:project, status: 'archived')
    end

    it '.active returns only active projects' do
      expect(Project.active.map(&:status)).to all(eq('active'))
    end
  end
end
