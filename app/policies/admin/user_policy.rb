class Admin::UserPolicy < Admin::ApplicationPolicy
	def login?
    admin_action? && record_exists?
  end  
end
