module Admin
	class Admin::JobViewsController < Admin::AdminController
		before_action -> { authorize auth_resource }, only: %i[index]

		def index
	    job_views 
	  end

	  def job_views
      @job_views = scope.includes(:job,:user).order_by_user.page(params[:page])
    end
	end
end