class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    record_exists?
  end

  def new?
    true
  end

  def create?
    new?
  end

  def edit?
    record_exists?
  end

  def update?
    edit?
  end

  def destroy?
    record_exists?
  end

  def logged?
    user.present?
  end

  def completed_profile?
    user.completed_profile?
  end

  def record_exists?
    record.present? && scope.where(id: record.id).exists?
  end
  
  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
