class ApplicationController < ActionController::Base
  include ResourceScopes

  before_action :configure_permitted_parameters, if: :devise_controller?

  def store_current_location
    store_location_for(:user, request.url)
  end

  @locale = :ar
  I18n.locale = :ar
  

protected

 def configure_permitted_parameters
  attributes = [:name, :country, :email, :role, :cv_file_name, :cv_content_type, :cv_file_size, :cv_updated_at, :deleted_at?]
  devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
  devise_parameter_sanitizer.permit(:account_update, keys: attributes)
 end

end
