class AuthController < ApplicationController

  def login
  end

  def logout
    reset_session
    redirect_to(:controller => :auth, :action => :login)
  end

end
