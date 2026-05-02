# frozen_string_literal: true

# app/serializers/comment_serializer.rb
class CommentSerializer
  include JSONAPI::Serializer

  attributes :body, :created_at
  belongs_to :user, serializer: UserSerializer, record_type: :user
end
