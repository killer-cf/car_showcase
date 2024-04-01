class StorePolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    user_is_super?
  end

  def update?
    user_is_super? || user_is_store_owner?
  end

  def destroy?
    user_is_super? || user_is_store_owner?
  end

  private

  def user_is_super?
    user&.super?
  end

  def user_is_store_owner?
    record.user_id == user&.id
  end
end
