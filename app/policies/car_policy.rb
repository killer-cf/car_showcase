class CarPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user_is_store_owner? || employee_admin?
  end

  def update?
    user_is_store_owner? || employee_admin?
  end

  def destroy?
    user_is_store_owner? || employee_admin?
  end

  private

  def user_is_store_owner?
    record.store.user_id == user&.id
  end

  def employee_admin?
    user&.employee&.store_id == record.store_id && user&.employee&.admin?
  end
end
