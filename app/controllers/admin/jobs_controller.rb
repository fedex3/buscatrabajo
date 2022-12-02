module Admin
  class Admin::JobsController < Admin::AdminController
    #before_action -> { authorize auth_resource }, only: %i[index new create]
    #before_action -> { authorize resource(job) }, only: %i[edit update destroy block]
    #before_action :authenticate_user!

    def index
      @grid = initialize_grid(scope.includes(:company), order: 'id', order_direction: 'desc', enable_export_to_csv: true, csv_file_name: 'Avisos')
      
      export_grid_if_requested
    end

    def new
      @job = Job.new
      @job.from_date = DateTime.now()
      @job.end_date = DateTime.now() + 90.days
    end

    def edit
      if params[:photo]
        @job.photo.clear
        @job.save
      end
    end

    def create
      @job = Job.new(job_params)
      publish if publish_button_pressed?

      if @job.save
        redirect_to admin_jobs_path
      else
        render 'new'
      end
    end

    def update
      publish if publish_button_pressed?

      if @job.update(job_params)
        params[:job_countries].each do |country|
          unless @job.job_countries.map{|a| a.country_alpha2}.include?(country)
            JobCountry.new(job_id: @job.id, country_alpha2: country).save
          end
        end

        unless @job.job_countries.blank?
          @job.job_countries.each do |job_country|
            unless params[:job_countries].include?(job_country.country_alpha2)
              job_country.destroy
            end
          end
        end

        redirect_to admin_jobs_path('grid[page]': params['previous_page'])
        
      else
        render 'edit'
      end
    end

    def destroy
      @job.destroy

      redirect_to admin_jobs_path
    end

    def block
      job.active ^= true
      job.save
      redirect_to admin_jobs_path('grid[page]': params['page'])
    end

    def publish_button_pressed?
      params['commit'] == I18n.t(:'admin.publish')
    end

    def publish
      @job.active = true
    end

    private
      def job_params
        params.require(:job).permit(:name, :email, :detail, :photo, :url, :city, :country, :views, 
          :active, :from_date, :end_date, :company_id, :industry_id, :part_time, :review_application, 
          :remote, :skill_list, :card_text)
      end

      def jobs
        @jobs ||= q_query.page(params[:page]).per(ENV['ADMIN_PAGE_SIZE'].to_i).order_by_date
      end

      def job
        @job ||= scope.find(params[:id])
      end
  end
end
