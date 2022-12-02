require 'ostruct'

class CompaniesController < ApplicationController

	def index
		@order = ENV['COMPANY_DEFAULT_ORDER']
    @order_columns = ENV['COMPANY_ORDER_COLUMNS'].split(',')

    if @order_columns.include?(params[:order])
    	@order = params[:order]
    end

    @companies = Company.includes(:industries).listable
    @recommended_companies = Company.order('RANDOM()').listable.limit(4)
    
    # Traigo todos los paises desde la gema
		all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		# Y traigo todos los paises que tengan Jobs activos
		listable_countries = Company.listable.distinct.pluck(:country)
		# Luego borro del array de todos los paises los que NO estan en el segundo array
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }

    @page_name = '/empresas'
    @canonical_url = ENV['HTTP_HOST'] + @page_name

    unless params[:country].blank?
      @companies = @companies.by_country(params[:country])
    end
    
    unless params[:q].blank?
      query = params[:q].downcase
      @canonical_url = @canonical_url + '/q-' + query
      @companies = @companies.by_name(query)
    end

		country_from_locale = [:ar, :cl, :co, :es, :mx].include?(I18n.locale) ? I18n.locale.upcase.to_s : 'AR'  

    @companies = Kaminari.paginate_array(@companies)
    @companies = @companies.page(params[:page]).per(10)

    unless params[:page].blank?
      @canonical_url = @canonical_url + '?page=' + params[:page].to_s
    end
  end

  def show
    Mobility.locale = :ar
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

    @recommended_companies = @company.recommended_companies.preload(:industries).select("companies.updated_at, companies.name, companies.name_id, companies.id, companies.main_photo_file_name, companies.main_photo_updated_at, companies.city, companies.active, companies.country")
    @recommended_jobs = @company.jobs.listable.preload(:company, :company).select("jobs.updated_at, jobs.active, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country").limit(4)

    @multioffice = false

    @page_name =  '/empresas/' + @param_name_id

    if @company.nil?
      redirect_to home_path and return
    else
      load_company_data
    end

    respond_to do |format|
      format.html
      format.js
    end
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

    @company_jobs     = @company.jobs.listable.order_by_date
    #view_email = !current_user.nil? ? current_user.email : (!cookies[:newsletter_email].nil? ? cookies[:newsletter_email].nil? : nil)
    #@company.viewed!
    #CompanyView.create(:company => @company, :user => current_user, :email => view_email) if view_email
  end


end
