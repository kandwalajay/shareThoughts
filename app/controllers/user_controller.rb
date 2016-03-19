require 'httparty'
require 'json'

class UsersController < ApplicationController
  # calling actions which require no session of user
  before_filter :require_no_user, :only => [:new, :signup]
  # calling actions which require session of user (means Login necessary)
  before_filter :require_user, :only => [:show, :edit, :update]

  # method for creating account of user
  def signup
    @status = 0
    @user = User.new(params[:user])
    # creating user credentials from sign-up form
    if @user.save
      @status = 1
      # Success - Create a new profile associated with user
      @user.build_profile
      @user.profile.save
      # Send welcome mail to the users who are successfully registered
      begin
        Email.welcome_email(@user, request.env["HTTP_HOST"]) || (raise Exception)
      rescue Exception => e
        logger.debug "Welcome mail is not send to user #{@user.email}"
      end
    end
    respond_to do |format|
      format.js
    end
  end

  # action for displaying the credentials of user while sign-up
  def show
    @user = current_user
  end

  # action for editing the details of user credentials which is used while sign-up
  def edit
    @user = current_user
  end

  # action for updating the details of user credentials which is used while sign-up
  def update
    @user = current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  # method used for signing up the new user who don't have account and check whether user is registered or not
  def facebook_signup
    random_password = rand.to_s[3..9]
    @fb_user = User.find_by_facebookId(params[:facebookId])
    if @fb_user.nil?
      # creating account of the user who are not registered with i-Net
      facebook_response = HTTParty.get('https://graph.facebook.com/me' +'?access_token='+params[:accessToken])
      response_code = facebook_response.response.code.to_i
      if response_code == 200
        # if response recieved from facebook is success (that is 200 code)
        facebook_user = JSON.parse facebook_response.response.body
        @user = User.find_by_email(facebook_user["email"])
        if @user
          # if email is registered but facebook id is not associated with the account
          @user.facebookId = params[:facebookId]
          @user.save
          @user_session = UserSession.create(@user, true)
          if @user_session.save
            # if session is saved then login the user to welcome page
            redirect_to welcome_profiles_path
          else
            # if session is not created / saved.
            flash[:notice] = I18n.t(:facebook_failure_1)
            render :controller => :user_sessions, :action => :new
          end
        else
          @user = User.new(
              :first_name => facebook_user["first_name"],
              :last_name => facebook_user["last_name"],
              :facebookId => params[:facebookId],
              :email => facebook_user["email"],
              :password => random_password,
              :password_confirmation => random_password
          )
          if @user.save
            # build and save profile for the new user of i-Net
            @user.build_profile
            @user.profile.save
            @user_session = UserSession.create(@user, true)
            if @user_session.save
              flash[:notice] = I18n.t(:login)
              redirect_to step_one_profiles_path
            else
              flash[:notice] = I18n.t(:facebook_failure_1)
              render :controller => :user_sessions, :action => :new
            end
          else
            flash[:notice] = I18n.t(:facebook_failure_1)
            render :controller => :user_sessions, :action => :new
          end
        end
      else
        # if response recieved from facebook is not Success (that is other than 200 code)
        flash[:notice] = I18n.t(:facebook_failure_1)
        render :controller => :user_sessions, :action => :new
      end
    else
      @user_session = UserSession.create(@fb_user, true)
      redirect_to welcome_profiles_path
    end
  end

  # action for sending the user to email domain
  def go_to_email
    domain = params[:target_email].split('@')[1]
    domain_name = "mail."+ domain
    begin
      response_success = HTTParty.get("https://#{domain_name}") || (raise Exception)
      if response_success.response.code.to_i == 200
        redirect_to "https://#{domain_name}"
      else
        failure_domain_target(domain)
      end
    rescue
      failure_domain_target(domain)
    end
  end

  # method for submitting the feedback form
  def feedback
    first_name = params[:first_name].strip()
    last_name = params[:last_name].strip()
    email = params[:email].strip()
    comments = params[:comments].strip()
    if Feedback.create(:first_name => first_name, :last_name => last_name, :email_address => email, :comment => comments)
      @feedback_status = "Success"
    else
      @feedback_status = "Failure"
    end
  end

  private

  # common method for selecting layout for different actions
  def layout_selection
    case params[:action]
      when "new","create"
        return "login_layout"
      else
        return "application"
    end
  end

  # common method for sending the target to domain name
  def failure_domain_target(domain)
    begin
      response_success = HTTParty.get("https://#{domain}") || (raise Exception)
      if response_success.response.code.to_i == 200
        redirect_to "https://#{domain}"
      else
        flash[:go_to_email_error] = I18n.t(:go_to_email_error_1)
        redirect_to root_path
      end
    rescue
      flash[:go_to_email_error] = I18n.t(:go_to_email_error_1)
      redirect_to root_path
    end
  end

end