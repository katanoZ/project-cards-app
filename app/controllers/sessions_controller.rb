class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_path, notice: user.message
  end
end
