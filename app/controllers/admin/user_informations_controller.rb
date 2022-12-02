module Admin
  class Admin::UserInformationsController < Admin::AdminController
    before_action -> { authorize auth_resource(klass: 'user', policy_klass: 'user_information')  }, only: %i[index]
    before_action -> { authorize resource(user, policy_klass: 'user_information') }, only: %i[show edit update]

    def index
      users
    end

    def show
    end

    def edit
    end

    def update
      @job_areas = JobArea.where(:id => params[:job_areas])
      @user.job_areas.destroy_all   #disassociate the already added job_areas
      @user.job_areas << @job_areas

      if @user.update(user_params)
        redirect_to admin_job_applications_path('grid[page]': params['previous_page'])
      else
        render 'edit'
      end
    end

    def user_params
       params.require(:user).permit(:email, :name, :country, :language, :rejected, :cv_status, :comment, :city, :study_level_id, :born_year)
    end

    private

    def job_area_query
      return study_level_query.by_job_area(params[:job_area]) if params[:job_area].present?
      study_level_query
    end

    def study_level_query
      return cv_status_query.by_study_level(params[:study_level]) if params[:study_level].present?
      cv_status_query
    end

    def cv_status_query
      return rejected_query.by_cv_status(params[:cv_status]) if params[:cv_status].present?
      rejected_query
    end

    def rejected_query
      return language_query.by_rejected(params[:rejected]) if params[:rejected].present?
      language_query
    end

    def language_query
      return q_query.by_language(params[:language]) if params[:language].present?
      q_query
    end

    def q_query
      return scope_controller.with_cv.by_q(query) if query.present?
      scope_controller.with_cv
    end

    def query
      @query ||= params[:q].downcase if params[:q].present?
    end


    def users
      @users ||= job_area_query.order_by_date.page(params[:page])
    end

    def user
      @user ||= scope_controller.find(params[:id])
    end

    def scope_controller
      if current_user.recruiter?
        scope(klass: 'user').where("users.id in (select distinct ja.user_id from job_applications ja inner join jobs j on j.id = ja.job_id where j.email = ?)", current_user.email)
      else
        scope(klass: 'user')
      end
    end
  end
end
