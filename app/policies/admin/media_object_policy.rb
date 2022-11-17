class Admin::MediaObjectPolicy < Admin::ApplicationPolicy

    def index?
        content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
    end

    def destroy?
        index?
    end
end