class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  before_action :current_user
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end
  
  helper_method :current_user, :logged_in?
end

