class UserSessionsController < ApplicationController
  # calling actions which require no session of user
  before_filter :require_no_user, :only => [:login]
  # calling actions which require session of user (means Login necessary)
  before_filter :require_user, :only => :destroy

  # method for creating session required for logging-in for user
  def login
    @status = 0
    @session = UserSession.new(params[:user_session])
    unless @session.save
      @status = 1
    end
    respond_to do |format|
      format.js
    end
  end

# action for destroying the session of user ( LogOut from session)
  def destroy
    current_user_session.destroy
    flash[:login_message] = I18n.t(:logout_message)
    redirect_to new_user_session_path
  end

# action for sending the password to user's registered email address
  def forgot_password
    @user = User.find_by_email(params[:email])
    if @user
      @status = I18n.t(:Success)
    else
      @status = I18n.t(:Failure)
    end
  end
end