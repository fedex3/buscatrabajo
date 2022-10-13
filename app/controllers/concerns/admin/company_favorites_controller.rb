module Admin
	class Admin::CompanyFavoritesController < Admin::AdminController
		before_action -> { authorize auth_resource }, only: %i[index]

		def index
	    company_favorites 
	  end

	  private

	  def company_favorites
      @company_favorites = scope.includes(:company,:user).order_by_user.page(params[:page])
    end

	end
end