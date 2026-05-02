# frozen_string_literal: true

# app/models/project_membership.rb
class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }
end
