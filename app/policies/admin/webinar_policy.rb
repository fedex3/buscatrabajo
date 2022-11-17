class Admin::WebinarPolicy < Admin::ApplicationPolicy
  def reminder_1_hour?
    community_manager_action? && record_exists?
  end  

  def reminder_1_day?
    community_manager_action? && record_exists?
  end  

  def thanks?
    community_manager_action? && record_exists?
  end

  def create_certificates?
    community_manager_action? && record_exists?
  end

  def send_certificates?
    community_manager_action? && record_exists?
  end
end
