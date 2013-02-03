class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_authenticated?
    if !session[:user_id]
      redirect_to(:controller => :auth, :action => :login)
      return false
    end
  end

  def user_authenticated_as_admin?
    if !session[:user_is_admin]
      redirect_to(:controller => :auth, :action => :login)
      return false
    end
  end

end
