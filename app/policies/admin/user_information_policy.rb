class Admin::UserInformationPolicy < Admin::ApplicationPolicy
  def scope
    Pundit.policy_scope!(user, user.class)
  end

	def index?
    recruiter_action?
  end

  def show?
    recruiter_action? && record_exists?
  end

  def edit?
    recruiter_action? || company_role_action? && record_exists?
  end

  def update?
    recruiter_action? || company_role_action? && record_exists?
  end
end
