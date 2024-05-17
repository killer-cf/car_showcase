class ModelPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user&.super?
  end

  def destroy?
    user&.super?
  end
end
