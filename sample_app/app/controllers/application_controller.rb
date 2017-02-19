class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  def authenticate
    unless logged_in?
	  store_location	
	  flash[:danger] = "Please log in."
      redirect_to root_url
    end
  end
end
