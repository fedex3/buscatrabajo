class Users::SessionsController < Devise::SessionsController
  #clear_respond_to

  # before_filter :configure_sign_in_params, only: [:create]

  #skip_filter :validate_terms, only: [:destroy]

  # GET /resource/sign_in
  def new
    super
    session[:from_event] = params[:from_event] if params[:from_event].present?
    session[:token] = params[:token] if params[:token].present?
  end

  # POST /resource/sign_in
  def create
    if params[:external_job_link].present?
      session[:external_job_link] = params[:external_job_link]
    elsif params[:internal_job_link].present?
      session[:internal_job_link] = params[:internal_job_link]
    end
    super
  end


  # DELETE /resource/sign_out
    #def destroy
      #super
    #end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  def after_sign_out_path_for(resource)
    if session[:from_event].present?
      company_special_event_path(session[:from_event], token: session[:token])
    else
      home_path #Cambiar para que te devuelva a la pagina anterior, no a la home. Al evento tampoco deberia redirigirte porque no te podes desloguear desde el evento y es molesto que a veces de la nada salis y apareces en un evento
    end
  end

  def after_sign_in_path_for(resource)
    if params[:soft_login_application].present?
      #If I was previously on a job application and applied by logging in
      if session[:external_job_link].present?
        job_application = JobApplication.new()
        job_application.create_application(@current_user.id, @current_user.email, session[:job_name_id])
        job_link = session[:external_job_link]
      elsif session[:internal_job_link].present?
        job_link = session[:internal_job_link]
      elsif session[:from_event].present?
        company_special_event_path(session[:from_event], token: session[:token])
      else
        home_path
      end

      params[:soft_login_application] = nil;
      session[:external_job_link] = nil;
      session[:internal_job_link] = nil;
      
      return job_link
    elsif session[:from_event].present?
      company_special_event_path(session[:from_event], token: session[:token])
    elsif current_user.from_event.present?
      company_special_event_path(current_user.from_event, token: session[:token])
    elsif params[:from_event].present?
      company_special_event_path(params[:from_event], token: session[:token])

    else
      home_path
      #super(resource)
    end

    # if current_user.terms?
    #  home_path
    # else
    #   edit_user_registration_path
    # end
  end
end
