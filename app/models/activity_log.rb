# frozen_string_literal: true

# app/models/activity_log.rb
class ActivityLog < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true

  validates :action, presence: true
end
