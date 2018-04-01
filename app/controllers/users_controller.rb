class UsersController < ApplicationController
  before_action :authenticate
  before_action :set_user, only: %i[edit update destroy]

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to root_path, notice: 'アカウント情報を更新しました'
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      reset_session
      redirect_to root_path, notice: '退会が完了しました。ユーザーを削除しました。'
    else
      flash.now[:alert] = '退会の処理に失敗しました'
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
