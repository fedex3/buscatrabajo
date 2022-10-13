module Admin
  class Admin::UsersController < Admin::AdminController
    before_action -> { authorize auth_resource }, only: %i[index]
    before_action -> { authorize resource(user) }, only: %i[show edit update destroy login ]

    def index
      @grid = initialize_grid(scope, order: 'id', order_direction: 'desc')
    end

    def show
    end

    def edit
    end

    def update

      if @user.update(user_params)
        if @user.company_role?
          UserMailer.welcome_company_user_email(@user).deliver_later
        end
        redirect_to admin_users_path
      else
        render 'edit'
      end
    end

    def destroy
      @user.destroy

      redirect_to admin_users_path
    end

    def login
    if !user.nil? && (user.role == 'basic' || current_user.superadmin? || current_user.admin?)
      sign_in user
      session[:admin_but_not_super] = !current_user.superadmin? ? true : false
    end
    redirect_to home_path
  end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :locale, :name, :country, :terms, :role, :terms_accepted_at, :admin, :company_id, newsletter_attributes: [:id, :subscribe])
    end

    def users
      @users = scope.order_by_date.page(params[:page])
    end

    def user
      @user ||= scope.find(params[:id])
    end
  end
end
