module Admin
  class Admin::JobApplicationsController < Admin::AdminController
    before_action :authenticate_user!
    before_action -> { authorize auth_resource }, only: %i[index]
    before_action -> { authorize resource(job_application) }, only: %i[send_mail destroy accept reject positive_reject put_on_standby to_pending]

    def index
      @grid = initialize_grid(scope.includes(:job, :user), order: 'id', order_direction: 'desc', enable_export_to_csv: true, csv_file_name: 'Postulaciones')
      export_grid_if_requested
    end

    def detailed
      @grid = initialize_grid(scope.includes(:job, :user, {user: :user_tests}).where(jobs: { id: params[:id] }), 
        order: 'user_tests.total', 
        custom_order: {'user_tests.total' => 'CASE WHEN user_tests.total IS NULL THEN 1 else 0 end, 
          user_tests.total desc, job_applications.id'},
        order_direction: 'desc', 
        enable_export_to_csv: true, csv_file_name: 'Postulaciones')
      @job = Job.find(params[:id])
      @company = @job.company
      @detailed = true
      export_grid_if_requested
    end
    
    def destroy
      @job_application.destroy

      redirect_to admin_job_applications_path
    end

    def send_mail
      @job_application.send_company_email(false)
      redirect_to admin_job_applications_path
    end

    def accept
      @job_application.accept! if @job_application.may_accept?
      redirect_to admin_job_applications_path('grid[page]': params['page'])
    end

    def reject
      @job_application.reject! if @job_application.may_reject?
      redirect_to admin_job_applications_path('grid[page]': params['page'])
    end

    def positive_reject
      @job_application.positive_reject! if @job_application.may_positive_reject?
      redirect_to admin_job_applications_path('grid[page]': params['page'])
    end

    def put_on_standby
      @job_application.put_on_standby! if @job_application.may_put_on_standby?
      redirect_to admin_job_applications_path('grid[page]': params['page'])
    end

    def to_pending
      @job_application.to_pending! if @job_application.may_to_pending?
      redirect_to admin_job_applications_path('grid[page]': params['page'])
    end

    private

    def job_application
      @job_application ||= scope.find(params[:id])
    end

    def job_applications
      @job_applications ||= company_query.order_by_date_desc.page(params[:page]).per(ENV['ADMIN_PAGE_SIZE'].to_i)
    end

  end
end
