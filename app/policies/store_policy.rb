class StorePolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    user&.super?
  end

  def update?
    user&.super? || user_is_store_owner?
  end

  def destroy?
    user&.super? || user_is_store_owner?
  end

  private

  def user_is_store_owner?
    record.user_id == user&.id
  end
end
