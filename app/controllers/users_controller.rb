class UsersController < ApplicationController
  before_action :authenticate

  def edit
    @user = current_user
  end

  def update
  end
end
