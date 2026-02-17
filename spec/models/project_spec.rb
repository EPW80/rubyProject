# spec/models/project_spec.rb
require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { build(:project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:client) }
    it 'enforces valid status values via enum' do
      expect(Project.statuses.keys).to match_array(%w[backlog active review on_hold completed archived])
      expect { build(:project, status: 'invalid_status') }.to raise_error(ArgumentError)
    end
    it { is_expected.to validate_numericality_of(:progress).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to have_many(:milestones).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:project_memberships) }
  end

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
