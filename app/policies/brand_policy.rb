class BrandPolicy < ApplicationPolicy
  def show?
    user&.super?
  end

  def index?
    true
  end

  def create?
    user&.super?
  end

  def update?
    user&.super?
  end

  def destroy?
    user&.super?
  end
end
