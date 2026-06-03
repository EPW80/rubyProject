# frozen_string_literal: true

# app/models/milestone.rb
class Milestone < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :due_date, presence: true

  scope :completed, -> { where(completed: true) }
  scope :pending,   -> { where(completed: false) }
  scope :due_soon,  -> { where(due_date: ..2.weeks.from_now) }
end
