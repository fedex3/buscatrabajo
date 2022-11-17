class Users::RegistrationsController < Devise::RegistrationsController
  # before_filter :configure_sign_up_params, only: [:create]
  #before_filter :configure_account_update_params, only: [:update]
  #skip_filter :validate_terms, only: [:edit, :update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    if current_user.present?
      if current_user.from_event.present? || session[:from_event].present?
        @event = CompanySpecialEvent.find_by(code: session[:from_event]) or not_found
        unless @event.present?
          @event = CompanySpecialEvent.find_by(code: current_user.from_event) or not_found
        end
        current_user.event_users.build(user_id: current_user.id,
          company_special_event_id: @event.id,
          first_name: current_user.name,
          email: current_user.email,
          country: current_user.country ,
          register_type: params[:user][:ticket_type]).save(validate: false) 
        event_user = EventUser.find_by(company_special_event_id: @event.id, email: current_user.email)
        EventUserMailer.links_email(event_user).deliver_later
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    @user = User.find(current_user.id)
    if @user.update(account_update_params)
      redirect_to perfil_path, notice: t('Edit_perfil_exitoso')
    else
      render :edit, alert: t('Edit_perfil_fallido')
    end
  end

  def update_through_event
    @user = User.find_by(id: current_user.id)
    if @user.update(account_update_params)
      render :json => {}
    else
      errors = ''
      @_user.errors.messages.each do |msg|
        errors = errors + User.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
      end
      render :json => {:errors => errors}, :status => 422
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def sign_up_params
    # devise_parameter_sanitizer.for(:sign_up) << :attribute
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :country, :terms_accepted, :terms_accepted_at, :analytics_client_id, :source, :term, :campaign, :medium, :from_event, :is_company)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def account_update_params
    # devise_parameter_sanitizer.for(:account_update) << :attribute
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation, :name, :country, :terms_accepted, :terms_accepted_at, :short_summary, :long_summary, :show_photo, :photo, :github_url, :linkedin_url, :language_list, :skill_list, :experience, newsletter_attributes: %i[id subscribe] )
  end

  def update_resource(resource, params)
    # Rails.logger.debug('PROVIDER:' + current_user.provider.to_s )
      resource.update_with_password(params)
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if current_user.is_company
      UserMailer.new_company_user_pending_email(current_user).deliver_later
      UserMailer.new_company_user_email(current_user).deliver_later
    end
    if current_user.from_event.present? || session[:from_event].present?
      flash[:notice] = "¡Gracias por registrarte al evento!"
      if session[:from_event].present?
        company_special_event_path(session[:from_event], token: session[:token], :just_created => "true")
      else
        company_special_event_path(current_user.from_event, token: session[:token], :just_created => "true")
      end
    else
      registration_thank_you_path
      #super(resource)
    end
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
