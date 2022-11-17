class Admin::EmailMarketingPolicy < Admin::ApplicationPolicy
	def duplicate?
    community_manager_action? && record_exists?
  end

  def test_mail?
    community_manager_action? && record_exists?
  end

  def send_mail?
    admin_action? && record_exists?
  end

  def schedule_mail?
    admin_action? && record_exists?
  end

  def cancel?
    admin_action? && record_exists?
  end
end
