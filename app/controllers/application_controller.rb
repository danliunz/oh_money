class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Almost all views need to display current user's info
  include ManageUserSession

  helper_method :user_signed_in?, :current_user

  # User authorization
  before_action :require_user_signin
end
