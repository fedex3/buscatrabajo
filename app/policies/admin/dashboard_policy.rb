class Admin::DashboardPolicy < Admin::ApplicationPolicy
  def index?
    super || recruiter_action? || company_role_action?
  end
end
