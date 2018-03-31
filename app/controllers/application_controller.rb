class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD'] if Rails.env.staging?

  helper_method :logged_in?, :current_user

  private
  def logged_in?
      !!session[:user_id]
  end

  def current_user
    return unless logged_in?
    @current_user ||= User.find(session[:user_id])
  end
end
