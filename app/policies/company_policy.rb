class CompanyPolicy < ApplicationPolicy
  def jobs_syncro?
    community_manager_action? && record_exists?
  end  
end
