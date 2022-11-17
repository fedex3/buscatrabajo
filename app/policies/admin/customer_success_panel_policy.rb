class Admin::CustomerSuccessPanelPolicy < Admin::ApplicationPolicy
  def show?
    superadmin? || admin? || content_editor? || content_editor_plus?
  end
end
