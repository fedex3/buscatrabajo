class Admin::AnalyticsPolicy < Admin::ApplicationPolicy
  def index?
    super || recruiter_action? || company_role_action?
  end
end
