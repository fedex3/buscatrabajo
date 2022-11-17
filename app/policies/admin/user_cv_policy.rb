
class Admin::UserCvPolicy < Admin::ApplicationPolicy
	
  def index?
    recruiter_action? || company_role_action?
  end  
end
