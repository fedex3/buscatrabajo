module Admin
  class AdminController < ApplicationController
    layout "admin"
    include AdminResourceScopes
    before_action :set_locale

    protected

    def not_authorized(exception)
      flash[:alert] = t(exception.class.to_s.downcase.gsub('::', '.'))
      redirect_to return_path
    end

    def return_path
      return admin_path if no_basic_role?
      home_path
    end

    def no_basic_role?
      return false unless user_signed_in?
       current_user.content_editor_plus? || current_user.content_editor? || current_user.recruiter? || current_user.community_manager? ||current_user.admin? || current_user.superadmin? || current_user.company_role?
    end

    def set_locale
      I18n.locale = :es
    end

  end
end
