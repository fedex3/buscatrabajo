class Admin::CompanyPolicy < Admin::ApplicationPolicy
  def stats?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

  def index?
    content_editor_plus_action? || content_editor_action? || super
  end

  def new?
    content_editor_plus_action? || content_editor_action? || super
  end

  def create?
    new?
  end

  def show?
    company_role_exclusive_action?
  end

  def edit?
    (content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?) && record_exists?
  end

  def edit_columns?
    edit?
  end

  def update?
    edit?
  end
end
