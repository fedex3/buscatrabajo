module AdminResourceScopes
  extend ActiveSupport::Concern

  included do
    def module_prefix
      'Admin::'
    end
  end
end
