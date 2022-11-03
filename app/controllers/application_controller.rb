class ApplicationController < ActionController::Base

  def store_current_location
    store_location_for(:user, request.url)
  end

  
end
