class CompanyFavoritesController < ApplicationController

  before_action :user_login
  def index
    @order = ENV['COMPANY_DEFAULT_ORDER']
    @order_columns = ENV['COMPANY_ORDER_COLUMNS'].split(',')
    if @order_columns.include?(params[:order])
    	@order = params[:order]
    end
    current_user or not_found
    order_by = @order == 'relevance' ? 'manual_order asc' : "#{@order} desc"
    @companies = current_user.company.preload(:industries).listable.order(order_by).page(params[:page])
  end	

  def create
		@company = Company.find(params[:company_id])

		errors = ''
		error = false

		if @company.nil?
			errors = 'Invalid Company Id'
			error = true
		end

		if current_user.nil?
			errors = 'Invalid User Id'
			error = true
		end

    if !error
    	@company_favorite = CompanyFavorite.find_by(:company_id => @company.id, :user_id => current_user.id)
    	save = false
    	if @company_favorite.nil?
	    	@company_favorite = current_user.company_favorites.build(:company_id => @company.id)
	    	save = @company_favorite.save
	    else
	    	save = @company_favorite.destroy
	    end

	 	 	if save
	      render :json => {}
	    else
	    	@company_favorite.errors.messages.each do |msg|
          errors = errors + CompanyFavorite.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
		    end
	      error = true
	    end
	  end
	  
	  if error
	  	render :json => {:errors => errors}, :status => 422
	  end
  end

  def user_login
    unless current_user
        redirect_to home_path
    end
  end
 
end
