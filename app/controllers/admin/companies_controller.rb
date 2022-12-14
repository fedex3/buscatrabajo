module Admin
  class Admin::CompaniesController < Admin::AdminController
    #before_action -> { authorize auth_resource }, only: %i[index new create offices_data]
    #before_action -> { authorize resource(company) }, only: %i[show edit update destroy jobs_syncro stats]

    attr_writer :remove_image

    def remove_image
      @remove_image || false
    end

    #require 'jwt'

    def index
      @all_companies = Company.all
      @total_companies = @all_companies.count
      @active_companies = @all_companies.active.count

      Mobility.locale = session[:admin_locale]
      @grid = initialize_grid(scope, order: 'id', order_direction: 'desc', enable_export_to_csv: true, csv_file_name: 'Empresas')
      export_grid_if_requested
    end

    def show
    end

    def new
      @company = Company.new
      @company.from_date = DateTime.now()
    end

    def edit
      @company ||= scope.find(params[:id])
      puts @company.inspect
      if params[:logo]
        @company.logo.destroy
        @company.save
      end
      if params[:icon]
        @company.icon.destroy
        @company.save
      end
      if params[:main_photo]
        @company.main_photo.destroy
        @company.save
      end
      if params[:cover_photo]
        @company.cover_photo.destroy
        @company.save
      end
    end

    def create
      @company = Company.new(company_params)
      @industries = Industry.where(:id => params[:industries])
      @company.industries << @industries


      if @company.save

        redirect_to admin_companies_path
      else
        render 'new'
      end
    end

    def update
      @company ||= scope.find(params[:id])
      @industries = Industry.where(:id => params[:industries])
      @company.industries.destroy_all   #disassociate the already added industries
      @company.industries << @industries

      if params[:delete_logo]
        @company.logo.clear
      end
      if params[:delete_icon]
        @company.icon.clear
      end
      if params[:delete_main_photo]
        @company.main_photo.clear
      end
      if params[:delete_cover_photo]
        @company.cover_photo.clear
      end

      if @company.update(company_params)
        @company.update(updated_at: DateTime.now) ##QUESTION: Why ? is supossed that updated_at is automatically set #CHECK IT
        redirect_to admin_companies_path
      else
        render 'edit'
      end
    end

    def destroy
      @company.destroy

      redirect_to admin_companies_path
    end

    def jobs_syncro
      if @company.jobs_syncronizable?
        @company.jobs_syncro
        redirect_to admin_companies_path
      end
    end

    def stats
      payload = {
        :resource => {:dashboard => 2},
        :params => {
          "id" => company.id
        },
        :exp => Time.now.to_i + (60 * 10) # 10 minute expiration
      }
    end

    private
      def company_params
        params.require(:company).permit(:name, :manual_order, :page_title, :meta_descript, :url, :long_summary, :job_provider_type, :job_provider_url, :job_register_url, :jobs_button,
          :proactive_interviews, :link_for_proactive_interviews, :logo, :icon, :main_photo, :city, :country, :views, :active, :from_date, :location, :jobs_text,
          :jobs_url, :email, :jobs_email, :logo_name, :list_label, :is_special_event_gold, :greenhouse_id, :facebook, :twitter, :linkedin, :card_text,
          :home, :phone, :show_whatsapp_button, :show_email_button, :featured_on_chile_home, :featured_on_spain_home, :order_in_event, :linkedin_username, :instagram, :cover_photo,
          :featured_on_mexico_home, :featured_on_colombia_home, :available_credits_for_tests, :show_tests, :enable_tests, :detail)
      end

      def companies
        @companies = scope.page(params[:page]).order_by_date
      end

      def company
        @company ||= scope.find(params[:id])
      end
  end
end
