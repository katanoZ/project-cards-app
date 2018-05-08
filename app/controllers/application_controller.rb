class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate

  if Rails.env.staging?
    http_basic_authenticate_with name: ENV.fetch('BASIC_AUTH_USERNAME'),
                                 password: ENV.fetch('BASIC_AUTH_PASSWORD')
  end

  helper_method :logged_in?, :current_user, :first_page?

  private

  def logged_in?
    session[:user_id].present? && User.exists?(session[:user_id])
  end

  def current_user
    return unless logged_in?
    @current_user ||= User.find(session[:user_id])
  end

  def authenticate
    return if logged_in?
    redirect_to login_path, alert: 'ログインしてください'
  end

  def first_page?
    params[:page].blank?
  end
end
