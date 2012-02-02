class AuthController < ApplicationController

  def login
    @remote_ip = request.remote_ip
  end

  def logout
    Log.application   = :auth_controller
    Log.event_source  = request.remote_ip
    Log.info("User logged out: #{session[:user_username]}(#{session[:user_id]})")
    reset_session
    redirect_to(:controller => :auth, :action => :login)
  end

end
