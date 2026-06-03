# frozen_string_literal: true

# spec/models/milestone_spec.rb
require 'rails_helper'

RSpec.describe Milestone, type: :model do
  subject { build(:milestone) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:due_date) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'scopes' do
    let(:project) { create(:project) }
    let!(:done)     { create(:milestone, project: project, completed: true, due_date: 1.month.from_now) }
    let!(:pending)  { create(:milestone, project: project, completed: false, due_date: 1.month.from_now) }
    let!(:imminent) { create(:milestone, project: project, completed: false, due_date: 3.days.from_now) }

    it '.completed returns only completed milestones' do
      expect(Milestone.completed).to contain_exactly(done)
    end

    it '.pending returns only incomplete milestones' do
      expect(Milestone.pending).to contain_exactly(pending, imminent)
    end

    it '.due_soon returns milestones due within two weeks' do
      expect(Milestone.due_soon).to include(imminent)
      expect(Milestone.due_soon).not_to include(pending)
    end
  end
end
