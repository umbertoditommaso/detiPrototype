class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper


  protected
  def localhost?
  	request.remote_ip == "127.0.0.1"
  end

  def authenticate
  	 redirect_to signin_url unless signed_in?
  end

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    sign_out
    super
  end
end
