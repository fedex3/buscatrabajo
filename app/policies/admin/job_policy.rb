class Admin::JobPolicy < Admin::ApplicationPolicy
	class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    recruiter_action? || company_role_action? || content_editor_action? || content_editor_plus_action?
  end

  def new?
    (recruiter_action? || company_role_action? || content_editor_action? || content_editor_plus_action?)
  end

  def create?
    new?
  end

  def edit?
    (recruiter_action? || company_role_action? || content_editor_action? || content_editor_plus_action?) && record_exists?
  end

  def update?
    edit?
  end

  def destroy?
    (recruiter_action? || company_role_action?) && record_exists?
  end

  def block?
    destroy? || content_editor_plus_action?
  end
end
