class AuthController < ApplicationController
  before_filter :set_log_parameters

  def login
  end

  def logout
    Log.info("User logged out: #{session[:user_username]}(#{session[:user_id]})")
    reset_session
    redirect_to(:controller => :auth, :action => :login)
  end

private

  def set_log_parameters
    Log.application   = :auth_controller
    Log.event_source  = request.remote_ip
  end

end
