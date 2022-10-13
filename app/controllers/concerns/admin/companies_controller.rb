module Admin
  class Admin::CompaniesController < Admin::AdminController
    before_action -> { authorize auth_resource }, only: %i[index new create offices_data]
    before_action -> { authorize resource(company) }, only: %i[show edit update destroy jobs_syncro stats]

    attr_writer :remove_image

    def remove_image
      @remove_image || false
    end



    require 'jwt'

    METABASE_SITE_URL = "https://metabase.mibucle.com"
    METABASE_SECRET_KEY = "c6bb6a134bc267477f9403d872518d8554b69428ef0c8f2e0aee787f2c000e1d"

    def index
      @all_companies = Company.all
      @total_companies = @all_companies.count
      @active_companies = @all_companies.active.count
      @active_gold_companies = @all_companies.active.gold.count
      @active_silver_companies = @all_companies.active.silver.count
      @active_bronze_companies = @all_companies.active.bronze.count
      @active_free_companies = @all_companies.active.free.count

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

      @company_special_events = CompanySpecialEvent.where(:id => params[:company_special_events])
      @company.company_special_events << @company_special_events

      if @company.save
        unless params[:company_countries].blank?
          params[:company_countries].each do |country|
            CompanyCountry.new(company_id: @company.id, country_alpha2: country).save
          end
        end

        unless params[:company_states].blank?
          params[:company_states].each do |state|
            CompanyState.new(company_id: @company.id, state_full_name: state).save
          end
        end

        redirect_to admin_companies_path
      else
        render 'new'
      end
    end

    def update
      @industries = Industry.where(:id => params[:industries])
      @company.industries.destroy_all   #disassociate the already added industries
      @company.industries << @industries

      @company_special_events = CompanySpecialEvent.where(:id => params[:company_special_events])
      @company.company_special_events.destroy_all   #disassociate the already added company_special_events
      @company.company_special_events << @company_special_events

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
        @company.update_attributes(updated_at: DateTime.now) ##QUESTION: Why ? is supossed that updated_at is automatically set #CHECK IT        
        unless @company.company_countries.blank?
          @company.company_countries.each do |company_country|
            company_country.destroy
          end
        end

        unless params[:company_countries].blank?
          params[:company_countries].each do |country|
            CompanyCountry.new(company_id: @company.id, country_alpha2: country).save
          end
        end
        
        unless @company.company_states.blank?
          @company.company_states.each do |company_state|
            company_state.destroy
          end
        end

        unless params[:company_states].blank?
          params[:company_states].each do |state|
            CompanyState.new(company_id: @company.id, state_full_name: state).save
          end
        end
    
        if current_user.company_role?
          redirect_to admin_company_info_path
        else
          redirect_to admin_companies_path
        end
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
      token = JWT.encode payload, METABASE_SECRET_KEY

      @iframe_url = METABASE_SITE_URL + "/embed/dashboard/" + token + "#bordered=true&titled=true"
    end

    private
      def company_params
        params.require(:company).permit(:name, :manual_order, :page_title, :meta_descript, :summary, :url, :long_summary, :job_provider_type, :job_provider_url, :job_register_url, :jobs_button,
          :proactive_interviews, :link_for_proactive_interviews, :logo, :icon, :main_photo, :city, :state, :country, :published, :views, :active, :from_date, :location, :pack, :jobs_text,
          :jobs_url, :email, :jobs_email, :logo_name, :list_label, :is_special_event_gold, :greenhouse_id, :facebook, :twitter, :linkedin, :card_text,
          :home, :show_only_in_special_events, :phone, :show_whatsapp_button, :show_email_button, :featured_on_chile_home, :featured_on_spain_home, :order_in_event, :linkedin_username, :instagram, :cover_photo,
          :featured_on_mexico_home, :featured_on_colombia_home, :available_credits_for_tests, :show_tests, :enable_tests, company_stories_attributes: [:id, :detail, :order, :title, :_destroy])
      end

      def companies
        @companies = scope.page(params[:page]).order_by_date
      end

      def company
        if current_user.company_role?
          @company ||= scope.find(current_user.company_id)
        else
          @company ||= scope.find(params[:id])
        end
      end
  end
end
