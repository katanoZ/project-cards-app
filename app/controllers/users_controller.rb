class UsersController < ApplicationController
  before_action :authenticate
  before_action :set_user, only:[:update]

  def edit
    @user = current_user.decorate
  end

  def update
    if @user.update(user_params)
      redirect_to root_path, notice: "アカウント情報を更新しました"
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :my_image, :my_image_cache)
  end

  def set_user
    @user = User.find(params[:id]).decorate
  end
end
