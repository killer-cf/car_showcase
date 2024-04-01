class BrandPolicy < ApplicationPolicy
  def show?
    user_is_super?
  end

  def index?
    user_is_super?
  end

  def create?
    user_is_super?
  end

  def update?
    user_is_super?
  end

  def destroy?
    user_is_super?
  end

  private

  def user_is_super?
    user&.super?
  end
end
