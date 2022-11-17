module Admin
  class Admin::JobAreasController < Admin::AdminController
    before_action -> { authorize auth_resource }, only: %i[index new create]
    before_action -> { authorize resource(job_area) }, only: %i[show edit update destroy]

    def index
      job_areas
    end

    def show
    end
   
    def new
      @job_area = JobArea.new
    end
   
    def edit
    end
   
    def create
      @job_area = JobArea.new(job_area_params)
   
      if @job_area.save
        redirect_to admin_job_areas_path
      else
        render 'new'
      end
    end
   
    def update
      if @job_area.update(job_area_params)
        redirect_to admin_job_areas_path
      else
        render 'edit'
      end
    end
   
    def destroy
      @job_area.destroy
   
      redirect_to admin_job_areas_path
    end
   
    private
      def job_area_params
        params.require(:job_area).permit(:name)
      end

      def job_areas
        @job_areas = scope.page(params[:page]).order_by_name
      end

      def job_area
        @job_area ||= scope.find(params[:id])
      end
  end
end