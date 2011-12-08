class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_authenticated?
    if !session[:user_id]
      redirect_to(:controller => :auth, :action => :index)
      return false
    end
  end

end
