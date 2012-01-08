class HomeController < ApplicationController

  before_filter :user_authenticated?

  def index
    session[:user_is_admin] = User.find(session[:user_id]).is_admin
  end

end
