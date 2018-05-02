class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  if Rails.env.staging?
    http_basic_authenticate_with name: ENV.fetch('BASIC_AUTH_USERNAME'),
                                 password: ENV.fetch('BASIC_AUTH_PASSWORD')
  end

  helper_method :logged_in?, :current_user, :logged_in_by_correct_user?

  private

  def logged_in?
    !!session[:user_id]
  end

  def current_user
    return unless logged_in?
    @current_user ||= User.find(session[:user_id])
  end

  def logged_in_by_correct_user?
    logged_in? && User.exists?(session[:user_id])
  end

  def authenticate
    return if logged_in_by_correct_user?
    redirect_to login_path, alert: 'ログインしてください'
  end
end
