module Admin
  class Admin::IndustriesController < Admin::AdminController
    #before_action -> { authorize auth_resource }, only: %i[index new create]
    before_action -> { authorize resource(industry) }, only: %i[show edit update destroy]

    def index
      industries 
    end

    def show
    end
   
    def new
      @industry = Industry.new
    end
   
    def edit
    end
   
    def create
      @industry = Industry.new(industry_params)
   
      if @industry.save
        redirect_to admin_industries_path
      else
        render 'new'
      end
    end
   
    def update
  
      if @industry.update(industry_params)
        redirect_to admin_industries_path
      else
        render 'edit'
      end
    end
   
    def destroy
      @industry.destroy
   
      redirect_to admin_industries_path
    end
   
    private
      def industry_params
        params.require(:industry).permit(:name)
      end

      def industries
        @industries = scope.page(params[:page]).order_by_name
      end

      def industry
        @industry ||= scope.find(params[:id])
      end
  end
end