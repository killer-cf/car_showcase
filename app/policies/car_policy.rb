class CarPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present?
  end
end
