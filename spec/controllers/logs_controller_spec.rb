require 'rails_helper'

RSpec.describe LogsController, type: :controller do
  describe '#index' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
        end

        it '正常にレスポンスを返すこと' do
          sign_in @user
          get :index, params: { project_id: @project.id }
          expect(response).to be_success
        end

        it '200レスポンスを返すこと' do
          sign_in @user
          get :index, params: { project_id: @project.id }
          expect(response).to have_http_status '200'
        end
      end

      context '権限のないユーザの場合' do
        before do
          @project = FactoryBot.create(:project)
        end

        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          sign_in @user
          expect {
            get :index, params: { project_id: @project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
      end

      it '302レスポンスを返すこと' do
        get :index, params: { project_id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :index, params: { project_id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
