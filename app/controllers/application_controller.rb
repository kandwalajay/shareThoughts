require 'mime/types'

class ApplicationController < ActionController::Base
  protect_from_forgery

  # added current_user_session and current_user method in helper methods so that they can be accessed in views as well
  helper_method :current_user_session, :current_user, :getFacebookAppId, :check_demos
  # all the method called before the application conntroller loads
  before_filter :set_locale

  # method for getting facebook id througout the site
  def getFacebookAppId
    config = YAML.load_file("#{Rails.root}/config/keys.yml")
    config["FacebookAppId"]
  end

# method for checking whether page demo is executed by the user
  def check_demos userId , demo_type
    demo = Demo.demo_data userId, demo_type
    unless demo.blank?
      return true
    else
      return false
    end
  end

  # method for checking whether user has admin access or not
  def is_admin_access
    if session[:is_admin] == "true"
      return true
    else
      if current_user.present?
        admin_status = User::ADMIN_ACCESS.include?(current_user.email)
        if admin_status
          session[:is_admin] = "true"
          return true
        else
          flash[:notice] = "You don't have admin access. You cannot access this page."
          redirect_to root_path
        end
      else
        flash[:notice] = "You don't have admin access. You cannot access this page."
        redirect_to root_path
      end
    end
  end

  # declaration of all private methods using private keyword
  private

  # used for calling all the messages from config/locals/en.yml
  # Setting locale settings
  def set_locale
    I18n.locale = params[:locale]
  end

  # starting of all the common methods used while creating sign-up and login process
  # used for finding the current user session (will be accessed throughout the controller)
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  # used for finding the current user (will be accessed throughout the controller)
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  # used for conditions where user will be required
  def require_user
    unless current_user
      flash[:failure_notice] = I18n.t(:require_user_message)
      redirect_to new_user_session_url
      return false
    end
  end

  # used for the conditions where user will not be required
  def require_no_user
    if current_user
      flash[:notice] = I18n.t(:require_no_user_message)
      redirect_to welcome_profiles_path
      return false
    end
  end

  # getting the redirect back or to default path as necessary
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # method for finding content type of uploaded file
  def get_content_type file
    mime_type = MIME::Types.type_for(file.original_filename)
    return mime_type.first ? mime_type.first : nil
  end

end
