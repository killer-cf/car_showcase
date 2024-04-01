class ModelPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
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
