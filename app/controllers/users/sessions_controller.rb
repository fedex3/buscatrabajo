class Users::SessionsController < Devise::SessionsController
  #clear_respond_to

  # before_filter :configure_sign_in_params, only: [:create]

  #skip_filter :validate_terms, only: [:destroy]

  # GET /resource/sign_in
  # def new
  #  super
  # end

  # POST /resource/sign_in
  # def create
  #  super
  # end


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
      home_path #Cambiar para que te devuelva a la pagina anterior, no a la home. Al evento tampoco deberia redirigirte porque no te podes desloguear desde el evento y es molesto que a veces de la nada salis y apareces en un evento
    end
  end

  def after_sign_in_path_for(resource)
      home_path
      #super(resource)
  end
end
