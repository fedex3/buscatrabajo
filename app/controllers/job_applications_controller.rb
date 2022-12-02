class JobApplicationsController < ApplicationController

  before_action :user_login, only: [:index]
  def index
    @order = ENV['JOB_DEFAULT_ORDER']
    @order_columns = ENV['JOB_ORDER_COLUMNS'].split(',')
    if @order_columns.include?(params[:order])
      @order = params[:order]
    end
    current_user or not_found

    @jobs = current_user.apply_job.preload(:company, :level, :industry).select("jobs.level_id, jobs.updated_at, jobs.part_time, jobs.industry_id, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country, jobs.remote").where(:job_applications => {:full => true}).includes(:company)

    case @order
      when 'relevance'    #compare to 1
        @jobs = @jobs.order_by_relevance
      when 'created_at'
        @jobs = @jobs.order_by_date
      else
        @jobs = @jobs.order_by_default
    end

    @jobs = @jobs.page(params[:page])
  end

  def new

  end

  def create
    if !params[:job_application].blank?
      if !params[:job_application_full_apply].blank?
        @job = Job.find(params[:job_id])
        unless @job.nil?
          unless current_user.nil?
            @user = current_user
            unless params[:job_application_user_cv].blank?
              @user_cv = UserCv.new
              @user_cv.user_id = @user.id
              @user_cv.cv = params[:job_application_user_cv]
              unless @user_cv.save
                errors = ''
                @user_cv.errors.messages.each do |msg|
                  errors = errors + UserCv.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
                end
                render :json => {:errors => errors}, :status => 422 and return
              end
            end
          else
            @user = User.new
            @user.name = params[:job_application_user_name]
            @user.password = params[:job_application_user_password]
            @user.password_confirmation = params[:job_application_user_password]
            @user.email = params[:job_application_user_email]
            @user.source = params[:job_application_user_source]
            @user.medium = params[:job_application_user_medium]
            @user.campaign = params[:job_application_user_campaign]
            @user.term = params[:job_application_user_term]
            @user.terms_accepted = true
            @user.country = @job.country
            if @user.save
              sign_in @user, :bypass => true
              @current_user ||= @user
            else
              errors = ''
              @user.errors.messages.each do |msg|
                errors = errors + User.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
              end
              render :json => {:errors => errors}, :status => 422 and return
            end
            @user_cv = UserCv.new
            @user_cv.user_id = @user.id
            @user_cv.cv = params[:job_application_user_cv]
            unless @user_cv.save
              errors = ''
              @user_cv.errors.messages.each do |msg|
                errors = errors + UserCv.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
              end
              render :json => {:errors => errors}, :status => 422 and return
            end
          end
          @job_application = JobApplication.find_by(user_id: @user.id, job_id: @job.id)
          if @job_application.nil?
            @job_application = JobApplication.new(job_application_params)
            @job_application.user_id = @user.id
            @job_application.job_id = @job.id
            @job_application.email = @user.email
            @job_application.full = true
            unless @user.user_cvs.active.take().nil?
              @job_application.user_cv_id = @user.user_cvs.active.take().id
            end
            #Falta ponerle el CV
            if @job_application.save
              company = Company.find_by(id: Job.find_by(id: @job_application.job_id).company_id)
              if ENV['TESTS_ENABLED'].to_boolean && company.enable_tests && !current_user.user_tests.present?
                create_test_for_job_applications
              end
              cid = nil
              unless params[:cid].blank?
                cid = params[:cid]
              end

              params[:special_event].present? ? @job_application.send_emails(params[:special_event]) : @job_application.send_emails
              if Rails.env.production?
                tracker = Staccato.tracker(ENV['ANALYTICS_TRACKING_ID'], cid)
                tracker.event(category: 'Job Application', action: 'Full Apply', label: @job.company.name + ' - ' + @job.name, value: 1)
              end
              respond_to do |format|
                format.html { }
                format.js   { }
                format.json { render :show, status: :created, location: @job_application }
              end
            else
              errors = ''
              @job_application.errors.messages.each do |msg|
                errors = errors + JobApplication.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
              end
              render :json => {:errors => errors}, :status => 422
            end
          else
            errors = t('job_application.fields.error.already_apply') + '<br>'
            render :json => {:errors => errors}, :status => 422
            #respond_to do |format|
              #format.html { }
              #format.json { render json: errors, status: :unprocessable_entity }
            #end
          end

        else
          errors = t('job_application.fields.error.general') + '<br>'
          render :json => {:errors => errors}, :status => 422
        end
      else
        @job = Job.find(params[:job_id])
        unless @job.nil?

          if current_user.nil? && cookies[:newsletter].blank?
            save = true

            @newsletter = Newsletter.find_by(email: params[:job_application][:email])
            if !@newsletter.nil?
              if !@newsletter.subscribe
                @newsletter.update_attributes(:subscribe => true)
              end
            else
              @newsletter = Newsletter.new
              @newsletter.email = params[:job_application][:email]
              @newsletter.source = params[:job_application][:source]
              @newsletter.medium = params[:job_application][:medium]
              @newsletter.campaign = params[:job_application][:campaign]
              @newsletter.term = params[:job_application][:term]
              @newsletter.country = @job.country
              @newsletter.origin = 'JOB_APPLICATION'
              save = @newsletter.save
            end

            if save
              cookies[:newsletter] = @newsletter.email
              cid = nil
              unless params[:cid].blank?
                cid = params[:cid]
              end
              if Rails.env.production?
                tracker = Staccato.tracker(ENV['ANALYTICS_TRACKING_ID'], cid)
                tracker.event(category: 'Newsletter', action: 'Newsletter Job Application', label: @newsletter.id.to_s, value: 1)
              end
            else
              errors = ''
              @newsletter.errors.messages.each do |msg|
                errors = errors + Newsletter.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
              end
              render :json => {:errors => errors}, :status => 422 and return
            end
          end

          @job_application = JobApplication.new
          @job_application.job_id = @job.id
          unless current_user.nil?
            @job_application.user_id = current_user.id
            @job_application.email = current_user.email
          else
            @user = User.new
            @user.name = params[:job_application][:name]
            @user.password = params[:job_application][:password]
            @user.password_confirmation = params[:job_application][:password]
            @user.email = params[:job_application][:email]
            @user.source = params[:job_application][:source]
            @user.medium = params[:job_application][:medium]
            @user.campaign = params[:job_application][:campaign]
            @user.term = params[:job_application][:term]
            @user.terms_accepted = true
            @user.country = params[:job_application][:country]
            if @user.save
              sign_in @user, :bypass => true
              @current_user ||= @user
              @job_application.email = @user.email
              @job_application.user_id = @user.id
            else
              errors = ''
              @user.errors.messages.each do |msg|
                errors = errors + User.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
              end
              render :json => {:errors => errors}, :status => 422 and return
            end
          end
          @job_application.full = false
          @job_application.save
          company = Company.find_by(id: Job.find_by(id: @job_application.job_id).company_id)
          if ENV['TESTS_ENABLED'].to_boolean &&  company.enable_tests && !current_user.user_tests.present?
              create_test_for_job_applications
          end
          cid = nil
          unless params[:cid].blank?
            cid = params[:cid]
          end
          if Rails.env.production?
            tracker = Staccato.tracker(ENV['ANALYTICS_TRACKING_ID'], cid)
            tracker.event(category: 'Job Application', action: 'Soft Apply', label: @job.company.name + ' - ' + @job.name, value: 1)
          end
          redirect_url = ""
          if @job.url.include?('?')
            redirect_url = @job.url + '&utm_source=mibucle'
          else
            redirect_url = @job.url + '?utm_source=mibucle'
          end
          render :json => {:redirect_url => redirect_url}

        else
          #No hago nada
        end
      end
    else
      redirect_to home_path
    end
  end

  def user_login
    unless current_user
        redirect_to home_path
    end
  end

  def create_test_for_job_applications
    if current_user.user_tests.blank?
      hirint = Hirint.new
      response = JSON.parse(hirint.login.body)
      token = response['token']
      name = current_user.name
      last_name, first_name = *name.reverse.split(/\s+/, 2).collect(&:reverse)
      first_name = last_name if first_name.nil?
      add_contact_into_opportunity = hirint.add_into_opportunity(token, first_name, last_name, current_user)
      add_contact_into_opportunity_body = JSON.parse(add_contact_into_opportunity.body)
      contact_id = add_contact_into_opportunity_body['id']
      if !contact_id.nil?
        @test = current_user.user_tests.new
        @test.user_id = current_user.id
        @test.hirint_contact_id = contact_id
        @test.save
        send_mail_data = hirint.send_mail(token, contact_id)
        if send_mail_data.code == '200'
          @test.update(sended_mail: true)
        end
      end
    else
      if current_user.user_tests.last.sended_mail != true
        hirint = Hirint.new
        response = JSON.parse(hirint.login.body)
        token = response['token']
        send_mail_data = hirint.send_mail(token, current_user.user_tests.last.hirint_contact_id)
        if send_mail_data.code == '200'
          current_user.user_tests.last.update(sended_mail: true)
        end
      end
    end
  end

  private
    def job_application_params
      params.require(:job_application).permit(:cv, :comment, :full)
    end
end