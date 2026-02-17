# app/serializers/milestone_serializer.rb
class MilestoneSerializer
  include JSONAPI::Serializer

  attributes :title, :description, :completed, :due_date
end
