class Admin::ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user.present?
    @user = user
    @record = record
  end

  def index?
    permitted_admin_user?
  end

  def show?
    permitted_admin_user? && record_exists?
  end

  def new?
    permitted_admin_user?
  end

  def create?
    new?
  end

  def edit?
    permitted_admin_user? && record_exists?
  end

  def update?
    edit?
  end

  def destroy?
    permitted_admin_user? && record_exists?
  end

  def record_exists?
    record.present? && scope.where(id: record.id).exists?
  end

  # role actions
  def company_role_action?
    company_role? || admin_action?
  end

  def company_role_exclusive_action?
    company_role_exclusive? || admin_action?
  end

  def recruiter_action?
    recruiter? || admin_action?
  end

  def community_manager_action?
   community_manager? || admin_action?
  end

  def content_editor_action?
   content_editor? || admin_action?
  end

  def content_editor_plus_action?
   content_editor_plus? || admin_action?
  end

  def admin_action?
    admin? || superadmin_action?
  end

  def superadmin_action?
    superadmin?
  end

  def external_admin_user?
     company_role? || recruiter? || permitted_admin_user? || content_editor? || content_editor_plus?
  end

  def permitted_admin_user?
     content_editor_plus? || content_editor? || community_manager? || admin? || superadmin?
  end

  def community_manager?
    user.community_manager?
  end

  def content_editor?
    user.content_editor?
  end

  def content_editor_plus?
    user.content_editor_plus?
  end

  def recruiter?
    user.recruiter?
  end

  def company_role?
    user.company_role?
  end

  def company_role_exclusive?
    user.company_role? && ENV['COMPANIES_AUTO_ADMIN'].split(',').map(&:to_i).include?(user.company_id)
  end

  def admin?
    user.admin?
  end

  def superadmin?
    user.superadmin?
  end

  def scope
    Pundit.policy_scope!(user, [:admin, record.class])
  end

  class Scope
    attr_reader :user

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def scope
      @scope.is_a?(Array) ? @scope.last : @scope
    end

    def resolve
      scope.all
    end

    def permitted_admin_user?
      content_editor_plus? || content_editor? || community_manager? || recruiter? || company_role? || admin? || superadmin?
    end

    def content_editor?
      user.content_editor?
    end

    def content_editor_plus?
      user.content_editor_plus?
    end

    def community_manager?
      user.community_manager?
    end

    def recruiter?
      user.recruiter?
    end

    def company_role?
      user.company_role?
    end

    def admin?
      user.admin?
    end

    def superadmin?
      user.superadmin?
    end
  end
end
