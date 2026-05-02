# frozen_string_literal: true

# app/policies/project_policy.rb
class ProjectPolicy < ApplicationPolicy
  def show?          = owner_or_member?
  def create?        = true
  def update?        = owner?
  def destroy?       = owner?
  def update_status? = owner?
  def activity?      = owner_or_member?

  class Scope < Scope
    def resolve
      scope.where(owner: user)
           .or(scope.where(id: user.project_memberships.select(:project_id)))
    end
  end

  private

  def owner?
    record.owner == user
  end

  def owner_or_member?
    owner? || record.project_memberships.exists?(user: user)
  end
end
