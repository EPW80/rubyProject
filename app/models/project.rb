# frozen_string_literal: true

# app/models/project.rb
class Project < ApplicationRecord
  include Discard::Model

  default_scope -> { kept }

  # ── Associations ──────────────────────────────────────────────────────────
  belongs_to :owner, class_name: 'User'
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :milestones, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────────────────
  validates :name,   presence: true, length: { minimum: 2, maximum: 120 }
  validates :client, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :tag_list_within_limits

  # ── Scopes ────────────────────────────────────────────────────────────────
  scope :active,     -> { where(status: 'active') }
  scope :completed,  -> { where(status: 'completed') }
  scope :by_client,  ->(client) { where(client: client) }
  scope :recent,     -> { order(updated_at: :desc) }
  scope :due_soon,   -> { where(deadline: ..2.weeks.from_now).where.not(status: 'completed') }

  # ── Enums ─────────────────────────────────────────────────────────────────
  enum :status, {
    backlog: 'backlog',
    active: 'active',
    review: 'review',
    on_hold: 'on_hold',
    completed: 'completed',
    archived: 'archived'
  }, prefix: true

  # ── Callbacks ─────────────────────────────────────────────────────────────
  after_create  :log_creation
  after_update  :log_status_change, if: :saved_change_to_status?

  # ── Instance Methods ──────────────────────────────────────────────────────

  # Recalculate progress from completed milestones
  def recalculate_progress!
    return update!(progress: 0) if milestones.none?

    completed_count = milestones.completed.count
    total_count     = milestones.count
    pct = ((completed_count.to_f / total_count) * 100).round
    update!(progress: pct)
  end

  # Days until deadline
  def days_remaining
    return nil unless deadline

    (deadline.to_date - Time.zone.today).to_i
  end

  def overdue?
    deadline.present? && deadline < Time.current && !status_completed?
  end

  def summary
    {
      id: id,
      name: name,
      client: client,
      status: status,
      progress: progress,
      milestones_due: milestones.pending.due_soon.count,
      overdue: overdue?,
      days_remaining: days_remaining
    }
  end

  private

  def tag_list_within_limits
    return if tag_list.blank?

    errors.add(:tag_list, 'cannot exceed 20 tags') if tag_list.size > 20
    errors.add(:tag_list, 'each tag must be under 50 characters') if tag_list.any? { |t| t.length > 50 }
  end

  def log_creation
    activity_logs.create!(action: 'created', user: owner, metadata: { status: status })
  end

  def log_status_change
    activity_logs.create!(
      action: 'status_changed',
      user: owner,
      metadata: { from: status_before_last_save, to: status }
    )
  end
end
