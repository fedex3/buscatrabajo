class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit show]

  def registration_newform
    respond_to do |format|
      format.html
      format.js
    end
  end

  def session_newform
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @user = User.find_by(id: current_user.id)
  end

  def edit
    @user = User.find_by(id: current_user.id)
  end

  def update 
    @user = User.find_by(id: current_user.id)
    if @user.update(user_params)
      render :json => {}
    else
      errors = ''
      @_user.errors.messages.each do |msg|
        errors = errors + User.human_attribute_name(msg[0].to_s)  + ': ' + msg[1][0].to_s + '<br>'
      end
      render :json => {:errors => errors}, :status => 422
    end
  end
end
