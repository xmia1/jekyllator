class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  # Helper method to return the current signed in user
  def current_user
    current_user ||= User.find_by(id: session[:user_id])
  end

  # Helper method to return boolean if a user is signed in currently or not
  def user_signed_in?
    !session[:user_id].nil?
  end

  helper_method :current_user
  helper_method :user_signed_in?
end
