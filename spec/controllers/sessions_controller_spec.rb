require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#create' do
    before do
      @user = FactoryBot.create(:user)
      allow(User).to receive(:find_or_create_from_auth).and_return(@user)
    end

    it 'find_or_create_from_authメソッドが呼び出されること' do
      expect(User).to receive(:find_or_create_from_auth)
      get :create, params: { provider: 'facebook' }
    end

    it 'セッションの値が作成されること' do
      get :create, params: { provider: 'facebook' }
      expect(session[:user_id]).to eq @user.id
    end

    it 'ルートにリダイレクトすること' do
      get :create, params: { provider: 'facebook' }
      expect(response).to redirect_to root_path
    end
  end

  describe '#destroy' do
    context 'ログイン済みの場合' do
      before do
        @user = FactoryBot.create(:user)
      end

      it 'セッションが削除されること' do
        sign_in @user
        delete :destroy
        expect(session[:user_id]).to eq nil
      end

      it 'ログイン画面にリダイレクトすること' do
        sign_in @user
        delete :destroy
        expect(response).to redirect_to login_path
      end
    end

    context '未ログインの場合' do
      it '302レスポンスを返すこと' do
        delete :destroy
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        delete :destroy
        expect(response).to redirect_to login_path
      end
    end
  end
end
