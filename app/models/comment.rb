# frozen_string_literal: true

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :body, presence: true
end
