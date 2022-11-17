class Admin::OfficePolicy < Admin::ApplicationPolicy
  def index?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def sort_mo1?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def sort_mo2?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def sort_mo3?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def sort_mo_nil?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def new?
    content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
  end

  def create?
    new?
  end

  def edit?
    (content_editor_plus_action? || content_editor_action? || super) && record_exists? || company_role_exclusive_action?
  end

  def edit_columns?
    edit? 
  end

  def update?
    edit? 
  end

  def destroy?
    edit?
  end
end
