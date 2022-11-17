class Admin::AdvicePolicy < Admin::ApplicationPolicy
  def offices_data?
    index?
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

  def edit?
    (content_editor_plus_action? || content_editor_action? || super) && record_exists?
  end

  def update?
    edit?
  end
end
