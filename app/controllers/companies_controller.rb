require 'ostruct'
require 'pqueue'

class CompaniesController < ApplicationController

	def index
		@order = ENV['COMPANY_DEFAULT_ORDER']
    @order_columns = ENV['COMPANY_ORDER_COLUMNS'].split(',')

    if @order_columns.include?(params[:order])
    	@order = params[:order]
    end

    @companies = Company.includes(:industries).listable.not_show_only_in_special_events
    @recommended_companies = Company.order('RANDOM()').not_show_only_in_special_events.listable.limit(4)

    @states = CompanyState.where(:company_id => Company.listable.map{|a| a.id}).map{|a| a.state_full_name}.uniq
    
    # Traigo todos los paises desde la gema
		all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		# Y traigo todos los paises que tengan Jobs activos
		listable_countries = CompanyCountry.where(:company_id => Company.listable.map{|a| a.id}).map{|a| a.country_alpha2}
		# Luego borro del array de todos los paises los que NO estan en el segundo array
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }

    @page_name = '/empresas'
    @canonical_url = ENV['HTTP_HOST'] + @page_name

    unless params[:country].blank?
      @companies = @companies.by_country(params[:country])
    end

    unless params[:state].blank?
      @companies = @companies.by_state(params[:state])
    end
    
    unless params[:q].blank?
      query = params[:q].downcase
      @canonical_url = @canonical_url + '/q-' + query
      @companies = @companies.by_name(query)
    end

		country_from_locale = [:ar, :cl, :co, :es, :mx].include?(I18n.locale) ? I18n.locale.upcase.to_s : 'AR'  

    @companies = @companies.order_by_country_photo_and_manual(country_from_locale, @order).uniq
    @companies = Kaminari.paginate_array(@companies)
    @companies = @companies.page(params[:page]).per(10)

    unless params[:page].blank?
      @canonical_url = @canonical_url + '?page=' + params[:page].to_s
    end
  end

  def show
    Mobility.locale = :es
    @param_name_id = params[:name_id].downcase

    if @param_name_id.starts_with? 'q-'
      param = @param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to companies_path(:q => query, :page => params[:page].to_s) and return
      else
        redirect_to companies_path(:q => query) and return
      end
    end

    @company = Company.preload(:industries).find_by(name_id: @param_name_id) or not_found

    @recommended_companies = @company.recommended_companies.preload(:industries).select("companies.updated_at, companies.name, companies.name_id, companies.id, companies.main_photo_file_name, companies.main_photo_updated_at, companies.city, companies.state, companies.active, companies.country")
    @recommended_jobs = @company.jobs.listable.preload(:company, :level, :company, :industry).select("jobs.level_id, jobs.updated_at, jobs.active, jobs.industry_id, jobs.part_time,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country").limit(4)
    @recommended_advices = @company.advices.listable.limit(2)

    @multioffice = false

    @page_name =  '/empresas/' + @param_name_id

    if @company.nil?
      redirect_to home_path and return
    else
      @multioffice = true if @company.multioffice?
      load_company_data
    end

    @canonical_url = ENV['HTTP_HOST'] + @page_name

		@company_special_event = CompanySpecialEvent.find_by(code: params[:special_event])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def preview
    @company = Company.find_by(name_id: params[:name_id])

    if @company
      @multioffice = @company.offices.count > 1
      load_company_data_for_preview

      @recommended_companies = @company.recommended_companies.preload(:industries).select("companies.updated_at, companies.name, companies.name_id, companies.id, companies.main_photo_file_name, companies.main_photo_updated_at, companies.city, companies.state, companies.active, companies.country")
      @recommended_jobs = @company.jobs.listable.preload(:company, :level, :company, :industry).select("jobs.level_id, jobs.updated_at, jobs.active, jobs.industry_id, jobs.part_time,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country").limit(4)
    else
      not_found
    end
    @preview   = true
    @page_name = '/empresas/' + @company.name_id
    @canonical_url = ENV['HTTP_HOST'] + @page_name
    render :show, :preview => true
  end

  def statistics
    company = Company.find_by(id: params[:company_name_id])
    if params[:button_clicked] == 'email_button'
      company.update(email_button_counter: (company.email_button_counter + 1 ))
    elsif params[:button_clicked] == 'whatsapp_button'
      company.update(whatsapp_button_counter: (company.whatsapp_button_counter + 1 ))
    elsif params[:button_clicked] == 'jobs_button'
      company.update(show_jobs_counter: (company.show_jobs_counter + 1 ))
    else 
      raise "Error. El tipo de botón no es correcto"
    end
  end

  protected

  def load_company_data
    if @multioffice
      @offices = @company.offices.listable.order_by_relevance
      if params[:office_name_id].present?
        @selected_office  = @company.offices.find_by(name_id: params[:office_name_id]) or not_found
        @page_name        =  '/empresas/' + @param_name_id + '/oficinas/' + @selected_office.name_id
      else
        @selected_office  = @offices.first
      end
      @selected_office_id = @selected_office.id
    else
      @office          = @company.office
      @company_stories = @company.stories
    end
    @company_jobs     = @company.jobs.listable.order_by_date

    view_email = !current_user.nil? ? current_user.email : (!cookies[:newsletter_email].nil? ? cookies[:newsletter_email].nil? : nil)
    @company.viewed!

    CompanyView.create(:company => @company, :user => current_user, :email => view_email) if view_email
  end

  def load_company_data_for_preview
    if @multioffice
      @offices  = @company.offices.order_by_relevance
      if params[:office_name_id].present?
        @selected_office  = @company.offices.find_by(name_id: params[:office_name_id]) or not_found
      else
        @selected_office  = @offices.first
      end
      @selected_office_id = @selected_office.id
    else
      @office          = @company.offices.first
      @company_stories = @company.stories
    end
    @company_jobs     = @company.jobs.active.order_by_date
  end
end
