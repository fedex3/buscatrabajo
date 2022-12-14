class JobsController < ApplicationController

  def index
    # TODO: Refactorear este método
    # 1. Cajas grandes
    #     1. País de la url (locale)
    #         1. Los más nuevos primero (created_at)
    #     2. Resto de los paises
    #         1. Los más nuevos primero (created_at)
    #     3. Filtros aplicados
    # 2. Cajas chicas
    #     1. País de la url (locale)
    #         1. Los más nuevos primero (created_at)
    #     2. Resto de los paises
    #         1. Los más nuevos primero (created_at)
    #     3. Filtros aplicados

		@order = ENV['JOB_DEFAULT_ORDER']
    @order_columns = Rails.cache.fetch(I18n.locale.to_s + "/jobs_order_columns", expires_in: 1.hours) do
      ENV['JOB_ORDER_COLUMNS'].split(',')
    end
    if @order_columns.include?(params[:order])
      @order = params[:order]
    end

		# Traigo todos los paises desde la gema
		all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		# Y traigo todos los paises que tengan Jobs activos
		listable_countries = Job.listable.distinct.pluck(:country)
		# Luego borro del array de todos los paises los que NO estan en el segundo array
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }

    country_from_locale = [:ar, :cl, :co, :cr, :es, :mx].include?(I18n.locale) ? I18n.locale.upcase.to_s : 'AR'

    # variables for select_tags input
		@industries = Industry.all

    @job_search_type = nil
    @job_search_value = nil
    @page_name =  '/trabajos'
    @canonical_url = ENV['HTTP_HOST'] + @page_name
    canonical_params = ''

    company = nil
    industry = nil

    param_empresa = params[:empresa]
    if param_empresa.blank?
      param_empresa = params[:company_name_id]
    end
    
    unless param_empresa.blank?
      param_company = param_empresa.downcase
      company_find = Company.find_by(name_id: param_company)
      unless company_find.nil?
        company = company_find.id
        @canonical_url += '/c-' + param_company
        @job_search_type = 'company'
        @job_search_value = company_find.name
      end
    end

    unless params[:industria].blank?
      param_industry = params[:industria].downcase
      canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '')
      industry_find = Industry.find_by(name_id: param_industry)
      unless industry_find.nil?
        industry = industry_find.id
        @canonical_url += '/i-' + param_industry
        @job_search_type = 'industry'
        @job_search_value = param_industry
      end
    end

    begin

      @jobs = Job.company_listable_not_only_special_events.listable.joins(:company).preload(:company).select("jobs.active, jobs.updated_at , jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country, jobs.remote")
      
      if company.present?
        @jobs = Job.company_listable.listable.joins(:company).preload(:company).select("jobs.active, jobs.updated_at , jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country, jobs.remote")
        @jobs = @jobs.by_company(company)

        @jobs = @jobs.where("companies.active = true")
      end
  
      unless industry.nil?
        @jobs = @jobs.by_industry(industry)
      end
  
      unless params[:remote].blank?
        param_remote = params[:remote].downcase
        canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '') + 'remote=' + param_remote
        @jobs = @jobs.by_remote(param_remote)
      end
  
      unless params[:q].blank?
        query = params[:q].downcase
        canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '') + 'q=' + query
        @jobs = @jobs.by_q(query)
      end
  
        
      if params[:country].blank?
        @jobs = Job.reorder_by_country(jobs: @jobs, locale: country_from_locale)
      else
        @jobs = @jobs.by_country(params[:country])
      end

      if params[:industry].present?
        @jobs = @jobs.by_industry(params[:industry])
      end
  
      @jobs = @jobs.tagged_with(params[:skills], any: true) if params[:skills].present?

      @jobs_not_found = false
      jobs_with_photos_ids = @jobs.with_photo.pluck(:id)
      jobs_without_photos_ids = @jobs.without_photo.pluck(:id)
      jobs_ids_ordered_by_photo = jobs_with_photos_ids + jobs_without_photos_ids
      @jobs = Job.get_and_order_by_ids(jobs_ids_ordered_by_photo) # this order can change the prev order
      @jobs = @jobs.page(params[:page])
      raise 'No se encontraron trabajos' if @jobs.blank?

    rescue RuntimeError, NoMethodError
      #@jobs = Job.recommended_jobs(params[:country].present? ? params[:country] : country_from_locale)
      @jobs_not_found = true

    ensure
      unless canonical_params.blank?
        @canonical_url = @canonical_url + '?' + canonical_params
      end
      unless params[:page].blank?
        @canonical_url = @canonical_url +  (canonical_params.blank? ? '?' : '&') +  'page=' + params[:page].to_s
      end
    end
  end  

  def preview
    param_name_id = params[:job_name_id].downcase
    param_company_name_id = params[:company_name_id].downcase

    @job = Job.includes(:company, :industry).find_by("companies.name_id": param_company_name_id, name_id: param_name_id) or not_found
    @recommended_jobs = @job.recommended_jobs.preload(:company, :company).select("jobs.updated_at ,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country, jobs.active")
    if @job.nil?
      redirect_to home_path and return
    end
    @preview   = true
    @page_name = '/empresas/' + param_company_name_id + '/trabajos/' + param_name_id
    @canonical_url = ENV['HTTP_HOST'] + @page_name

    all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		listable_countries = Company.listable.distinct.pluck(:country)
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }
    @job_application = JobApplication.new()
    
    render :show, :preview => true

  end

  def show
    param_name_id = params[:name_id]
    param_company_name_id = params[:company_name_id]

    @job = Job.includes(:company).find_by("companies.name_id": param_company_name_id, name_id: param_name_id)

    all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		listable_countries = Company.listable.distinct.pluck(:country)
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }
  

    if @job.nil? || !@job
      #redirect_to home_path and return
    else

      view_email = nil
      unless current_user.nil?
        view_email = current_user.email
      else
        unless cookies[:newsletter_email].nil?
          view_email = cookies[:newsletter_email]
        end
      end
      @job.update_column(:views, @job.views+1)
      unless view_email.nil?
        #JobView.create(:job => @job, :user => current_user, :email => view_email)
      end
    end

    @has_apply = false
    unless current_user.nil?
      unless current_user.job_applications.job(@job.id).take().nil?
        @has_apply = true
      end
    end
    @job_application = JobApplication.new()
  end
end

