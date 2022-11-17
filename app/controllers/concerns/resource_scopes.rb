module ResourceScopes
  extend ActiveSupport::Concern

  included do
    attr_reader :scope

    # Resources
    def auth_resource(klass: controller_name, policy_klass: klass)
      resource_class(klass).new(policy_class: resource_policy_class(policy_klass))
    end

    def resource(resource, policy_klass: resource.class)
      return auth_resource unless resource.present?
      resource.policy_class(resource_policy_class(policy_klass))
      resource
    end

    # Scopes
    def scope(klass: controller_name)
      @scope = resource_scope(klass).new(current_user, resource_class(klass)).resolve
    end

    private

    def resource_class(klass)
      policy_class(klass).constantize
    end

    def resource_scope(klass)
      "#{resource_policy_class(klass)}::Scope".constantize
    end

    def resource_policy_class(klass)
      "#{module_prefix}#{policy_class(klass)}Policy"
    end

    def policy_class(klass)
      klass.to_s.classify
    end

    def module_prefix; end
  end
end
