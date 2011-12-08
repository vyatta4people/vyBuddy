class HomeController < ApplicationController

  before_filter :user_authenticated?

  def index
  end

end
