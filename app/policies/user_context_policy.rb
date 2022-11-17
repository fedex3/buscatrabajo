class UserContextPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def edit?
    record_exists?
  end

  def update?
    record_exists?
  end

  def scope
    Pundit.policy_scope!(user, user.class)
  end
end