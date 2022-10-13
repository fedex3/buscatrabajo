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

    if params[:special_event].present?
      @company_special_event = CompanySpecialEvent.find_by(code: params[:special_event])
    end

		# Traigo todos los paises desde la gema
		all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		# Y traigo todos los paises que tengan Jobs activos
		listable_countries = JobCountry.where(:job_id => Job.listable.map{|a| a.id}).map{|a| a.country_alpha2}
		# Luego borro del array de todos los paises los que NO estan en el segundo array
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }

    country_from_locale = [:ar, :cl, :co, :cr, :es, :mx].include?(I18n.locale) ? I18n.locale.upcase.to_s : 'AR'

    # variables for select_tags input
		@industries = Industry.all
		@levels = Level.all
		@states = JobState.where(:job_id => Job.listable.map{|a| a.id}).map{|a| a.state_full_name}.uniq

    @job_search_type = nil
    @job_search_value = nil
    @page_name =  '/trabajos'
    @canonical_url = ENV['HTTP_HOST'] + @page_name
    canonical_params = ''

    company = nil
    industry = nil
    level = nil

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

    unless params[:nivel].blank?
      param_level = params[:nivel].downcase
      canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '')
      level_find = Level.find_by(name_id: param_level)
      unless level_find.nil?
        level = level_find.id
        @canonical_url += '/l-' + param_level
        @job_search_type = 'level'
        @job_search_value = param_level
      end
    end

    begin
      if @company_special_event.present?
        @jobs = Job.company_listable.listable.joins(:company).preload(:company, :level, :industry).select("jobs.level_id, jobs.active, jobs.updated_at, jobs.industry_id, jobs.part_time, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.remote") 
        @jobs = @jobs.where("company_id in (select company_id from companies_company_special_events where company_special_event_id = " + @company_special_event.id.to_s + ") ")
      else
        @jobs = Job.company_listable_not_only_special_events.listable.joins(:company).preload(:company, :level, :industry).select("jobs.level_id, jobs.active, jobs.updated_at, jobs.industry_id, jobs.part_time, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.remote")
      end
      
      if company.present?
        @jobs = Job.company_listable.listable.joins(:company).preload(:company, :level, :industry).select("jobs.level_id, jobs.active, jobs.updated_at, jobs.industry_id, jobs.part_time, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.remote")
        @jobs = @jobs.by_company(company)
      elsif !@company_special_event.present?
        @jobs = @jobs.where("companies.active = true")
      end
  
      unless industry.nil?
        @jobs = @jobs.by_industry(industry)
      end
  
      unless level.nil?
        @jobs = @jobs.by_level(level)
      end
  
      unless params[:estado].blank?
        param_state = params[:estado]
        canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '') + 'state=' + param_state
        @jobs = @jobs.by_state(param_state.gsub('-',' '))
      end
  
      unless params[:part_time].blank?
        param_part_time = params[:part_time].downcase
        canonical_params = canonical_params + (!canonical_params.blank? ? '&' : '') + 'part_time=' + param_part_time
        @jobs = @jobs.by_part_time(param_part_time)
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
  
      case @order
      when 'relevance'    #compare to 1
        @jobs = @jobs.order_by_relevance
      when 'created_at'
        @jobs = @jobs.order_by_date
      else
        @jobs = @jobs.order_by_default
      end
  
      unless params[:state].blank?
        @jobs = @jobs.by_state(params[:state])
      end
        
      if params[:country].blank?
        @jobs = Job.reorder_by_country_and_all_remotes(jobs: @jobs, locale: country_from_locale, order: @order)
      else
        @jobs = @jobs.by_country(params[:country])
      end

      if params[:industry].present?
        @jobs = @jobs.by_industry(params[:industry])
      end
  
      if params[:level].present?
        @jobs = @jobs.by_level(params[:level])
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
      @jobs = Job.recommended_jobs(params[:country].present? ? params[:country] : country_from_locale)
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

    @job = Job.includes(:company, :level, :industry).find_by("companies.name_id": param_company_name_id, name_id: param_name_id) or not_found
    @recommended_jobs = @job.recommended_jobs.preload(:company, :level, :company, :industry).select("jobs.level_id, jobs.updated_at, jobs.industry_id, jobs.part_time,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.active")
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
    param_name_id = params[:name_id].downcase

    if param_name_id.starts_with? 'q-'
      param = param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to jobs_path(:q => query, :page => params[:page].to_s) and return
      else
        redirect_to jobs_path(:q => query) and return
      end
    end

    if param_name_id.starts_with? 'c-'
      param = param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to jobs_path(:empresa => query, :page => params[:page].to_s) and return
      else
        redirect_to jobs_path(:empresa => query) and return
      end
    end

    if param_name_id.starts_with? 'o-'
      param = param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to jobs_path(:pais => query, :page => params[:page].to_s) and return
      else
        redirect_to jobs_path(:pais => query) and return
      end
    end

    if param_name_id.starts_with? 'l-'
      param = param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to jobs_path(:nivel => query, :page => params[:page].to_s) and return
      else
        redirect_to jobs_path(:nivel => query) and return
      end
    end

    if param_name_id.starts_with? 'i-'
      param = param_name_id.split(//)
      query = param.last(param.length - 2).join
      unless params[:page].blank?
        redirect_to jobs_path(:industria => query, :page => params[:page].to_s) and return
      else
        redirect_to jobs_path(:industria => query) and return
      end
    end

    param_company_name_id = params[:company_name_id].downcase

    @company_special_event = CompanySpecialEvent.find_by(code: params[:special_event])

    @job = Job.includes(:company, :level, :industry).find_by("companies.name_id": param_company_name_id, name_id: param_name_id) or not_found

    all_countries = ISO3166::Country.all.map{ |x| {"name" => x.translation('es'), "alpha2" => x.alpha2} }.sort_by!{ |x| x["name"] }
		listable_countries = Company.listable.distinct.pluck(:country)
		@countries = all_countries.keep_if{ |country| country["alpha2"].in? listable_countries }
    
    if @company_special_event.nil?
      @recommended_jobs = @job.recommended_jobs.company_listable.listable.preload(:company, :level, :company, :industry).select("jobs.level_id, jobs.updated_at, jobs.industry_id, jobs.part_time,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.active")
    else
      @recommended_jobs = @job.recommended_jobs.company_listable.listable.by_company_in_special_event(@company_special_event.code).preload(:company, :level, :company, :industry).select("jobs.level_id, jobs.updated_at, jobs.industry_id, jobs.part_time,jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.active")
    end

    if @job.nil? || !@job.published
      redirect_to home_path and return
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
        JobView.create(:job => @job, :user => current_user, :email => view_email)
      end
    end

    @page_name = '/empresas/' + param_company_name_id + '/trabajos/' + param_name_id
    @canonical_url = ENV['HTTP_HOST'] + @page_name

    @has_apply = false
    unless current_user.nil?
      unless current_user.job_applications.job(@job.id).take().nil?
        @has_apply = true
      end
    end
    @job_application = JobApplication.new()
  end
end

