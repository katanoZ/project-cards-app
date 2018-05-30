require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#update' do
    before do
      @user = FactoryBot.create(:user, name: '古い名前')
    end

    context 'ログインユーザの場合' do
      context '有効な属性値の場合' do
        before do
          @user_params = FactoryBot.attributes_for(:user, name: '新しい名前')
        end
        it 'ユーザを更新できること' do
          sign_in @user
          patch :update, params: { id: @user.id, user: @user_params }
          expect(@user.reload.name).to eq '新しい名前'
        end

        it 'ルート画面にリダイレクトすること' do
          sign_in @user
          patch :update, params: { id: @user.id, user: @user_params }
          expect(response).to redirect_to root_path
        end
      end

      context '無効な属性値の場合' do
        before do
          @user_params = FactoryBot.attributes_for(:user, :invalid)
        end

        it 'ユーザを更新できないこと' do
          sign_in @user
          patch :update, params: { id: @user.id, user: @user_params }
          expect(@user.reload.name).to eq '古い名前'
        end

        it 'テンプレートを再表示すること' do
          sign_in @user
          patch :update, params: { id: @user.id, user: @user_params }
          expect(response).to render_template :edit
        end
      end
    end

    context '未ログインの場合' do
      before do
        @user_params = FactoryBot.attributes_for(:user)
      end

      it '302レスポンスを返すこと' do
        patch :update, params: { id: @user.id, user: @user_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        patch :update, params: { id: @user.id, user: @user_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインユーザの場合' do
      it 'ユーザを削除できること' do
        sign_in @user
        expect {
          delete :destroy, params: { id: @user.id }
        }.to change(User, :count).by(-1)
      end

      it 'セッションの値がクリアされていること' do
        sign_in @user
        delete :destroy, params: { id: @user.id }
        expect(session[:user_id]).to eq nil
      end

      it 'ログイン画面にリダイレクトすること' do
        sign_in @user
        delete :destroy, params: { id: @user.id }
        expect(response).to redirect_to login_path
      end
    end

    context '未ログインの場合' do
      it '302レスポンスを返すこと' do
        delete :destroy, params: { id: @user.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        delete :destroy, params: { id: @user.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
