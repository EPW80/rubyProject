# frozen_string_literal: true

# app/serializers/project_serializer.rb
class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :client, :description, :status, :progress,
             :color, :deadline, :category, :tag_list, :created_at, :updated_at

  belongs_to :owner, serializer: UserSerializer, record_type: :user
  has_many   :milestones, serializer: MilestoneSerializer
  has_many   :members,    serializer: UserSerializer, record_type: :user
  has_many   :comments,   serializer: CommentSerializer
end
