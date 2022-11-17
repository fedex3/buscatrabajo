module Admin
  class Admin::SettingsController < Admin::AdminController
    before_action -> { authorize [:admin, :setting] }

    def create
      setting_params.keys.each do |key|
        unless setting_params[key].nil?
          Setting.send("#{key}=", setting_params[key].strip)
        end
      end
      redirect_to admin_settings_path, notice: Setting.human_attribute_name("updated_successfully")
    end

    private

    def setting
      @setting ||= scope.find(params[:id])
    end

    def setting_params
      params.require(:setting).permit(:show_homepage_banner, :homepage_banner_text,
        :show_subheader_jobs, :show_subheader_company_job, :show_subheader_company,
        :subheader_jobs_text, :subheader_notes_text, :subheader_notes_button_text,
        :subheader_notes_url, :show_main_popup, :show_main_popup_image, :main_popup_image_url,
        :main_popup_image_link, :show_main_popup_button, :main_popup_button_text,
        :main_popup_button_url, :show_subheader_notes)
    end
  end
end
