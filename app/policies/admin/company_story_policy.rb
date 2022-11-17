class Admin::CompanyStoryPolicy < Admin::ApplicationPolicy
    def new?
        content_editor_plus_action? || content_editor_action? || super || company_role_exclusive_action?
    end
    
    def create?
        new?
    end
    
    def edit?
        (content_editor_plus_action? || content_editor_action? || super) && record_exists? || company_role_exclusive_action?
    end

    def update?
        edit? 
    end
end
