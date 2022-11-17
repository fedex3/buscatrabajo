module Admin
  class Admin::LevelsController < Admin::AdminController
    before_action -> { authorize auth_resource }, only: %i[index new create]
    before_action -> { authorize resource(level) }, only: %i[show edit update destroy]

    def index
      levels
    end

    def show
    end
   
    def new
      @level = Level.new
    end
   
    def edit
    end
   
    def create
      @level = Level.new(level_params)
   
      if @level.save
        redirect_to admin_levels_path
      else
        render 'new'
      end
    end
   
    def update
      if @level.update(level_params)
        redirect_to admin_levels_path
      else
        render 'edit'
      end
    end
   
    def destroy
      @level.destroy
   
      redirect_to admin_levels_path
    end
   
    private
      def level_params
        params.require(:level).permit(:name, :order)
      end

      def levels
        @levels = scope.page(params[:page]).order_by_name
      end

      def level
        @level ||= scope.find(params[:id])
      end
  end
end