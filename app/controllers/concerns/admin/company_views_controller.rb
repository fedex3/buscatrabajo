module Admin
	class Admin::CompanyViewsController < Admin::AdminController
		before_action -> { authorize auth_resource }, only: %i[index]
    
		def index
	    @company_views = CompanyView.all.includes(:company,:user).order_by_user.page(params[:page])
	  end

	  private

	  def company_views
      @company_views = scope.includes(:company,:user).order_by_user.page(params[:page])
    end
	end
end