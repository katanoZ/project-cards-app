class UsersController < ApplicationController
  before_action :authenticate
  before_action :set_user, only: %i[edit update]

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to root_path, notice: 'アカウント情報を更新しました'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :image, :image_cache)
  end

  def set_user
    @user = current_user
  end
end
