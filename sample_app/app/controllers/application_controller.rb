class ApplicationController < ActionController::Base
  
  include SessionsHelper

  def authenticate
    unless logged_in?
	  store_location
	  flash[:danger] = "Please log in."
      redirect_to root_url
    end
  end
end
