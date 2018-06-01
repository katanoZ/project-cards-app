require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe '#index' do
    context 'ログインしている場合' do
      before do
        @user = FactoryBot.create(:user)
      end

      it '正常にレスポンスを返すこと' do
        sign_in @user
        get :index
        expect(response).to be_success
      end

      it '200レスポンスを返すこと' do
        sign_in @user
        get :index
        expect(response).to have_http_status '200'
      end
    end

    context 'ログインしていない場合' do
      it '302レスポンスを返すこと' do
        get :index
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :index
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#show' do
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
          get :show, params: { id: @project.id }
          expect(response).to be_success
        end

        it '200レスポンスを返すこと' do
          sign_in @user
          get :show, params: { id: @project.id }
          expect(response).to have_http_status '200'
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          sign_in @user
          expect {
            get :show, params: { id: project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
      end

      it '302レスポンスを返すこと' do
        get :show, params: { id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :show, params: { id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#create' do
    context 'ログインしている場合' do
      before do
        @user = FactoryBot.create(:user)
      end

      context '有効な属性値の場合' do
        before do
          @project_params = FactoryBot.attributes_for(:project)
        end

        it 'プロジェクトが作成できること' do
          sign_in @user
          expect {
            post :create, params: { project: @project_params }
          }.to change(@user.projects, :count).by(1)
        end

        it 'マイプロジェクト一覧画面にリダイレクトすること' do
          sign_in @user
          post :create, params: { project: @project_params }
          expect(response).to redirect_to myprojects_path
        end
      end

      context '無効な属性値の場合' do
        before do
          @project_params = FactoryBot.attributes_for(:project, :invalid)
        end

        it 'プロジェクトが作成できないこと' do
          sign_in @user
          expect {
            post :create, params: { project: @project_params }
          }.to change(@user.projects, :count).by(0)
        end

        it 'テンプレートを再表示すること' do
          sign_in @user
          post :create, params: { project: @project_params }
          expect(response).to render_template :new
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project_params = FactoryBot.attributes_for(:project)
      end

      it '302レスポンスを返すこと' do
        post :create, params: { project: @project_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        post :create, params: { project: @project_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#update' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user, name: '古い名前')
        end

        context '有効な属性値の場合' do
          before do
            @project_params = FactoryBot.attributes_for(:project, name: '新しい名前')
          end

          it 'プロジェクトが更新できること' do
            sign_in @user
            patch :update, params: { id: @project.id, project: @project_params }
            expect(@project.reload.name).to eq '新しい名前'
          end

          it 'マイプロジェクト画面にリダイレクトすること' do
            sign_in @user
            patch :update, params: { id: @project.id, project: @project_params }
            expect(response).to redirect_to myprojects_path
          end
        end

        context '無効な属性値の場合' do
          before do
            @project_params = FactoryBot.attributes_for(:project, :invalid)
          end

          it 'プロジェクトが更新できないこと' do
            sign_in @user
            patch :update, params: { id: @project.id, project: @project_params }
            expect(@project.reload.name).to eq '古い名前'
          end

          it 'テンプレートを再表示すること' do
            sign_in @user
            patch :update, params: { id: @project.id, project: @project_params }
            expect(response).to render_template :edit
          end
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          project_params = FactoryBot.attributes_for(:project)
          sign_in @user
          expect {
            patch :update, params: { id: project.id, project: project_params }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @project_params = FactoryBot.attributes_for(:project)
      end

      it '302レスポンスを返すこと' do
        patch :update, params: { id: @project.id, project: @project_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        patch :update, params: { id: @project.id, project: @project_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    context 'ログインしている場合' do
      before do
        @user = FactoryBot.create(:user)
      end

      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
        end

        it 'プロジェクトが削除できること' do
          sign_in @user
          expect {
            delete :destroy, params: { id: @project.id }
          }.to change(Project, :count).by(-1)
        end

        it 'マイプロジェクト画面にリダイレクトすること' do
          sign_in @user
          delete :destroy, params: { id: @project.id }
          expect(response).to redirect_to myprojects_path
        end
      end

      context '権限のないユーザの場合' do
        before do
          @project = FactoryBot.create(:project)
        end

        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          sign_in @user
          expect {
            delete :destroy, params: { id: @project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project)
      end

      it '302レスポンスを返すこと' do
        delete :destroy, params: { id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        delete :destroy, params: { id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#invite' do
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
          get :invite, params: { id: @project.id }
          expect(response).to be_success
        end

        it '200レスポンスを返すこと' do
          sign_in @user
          get :invite, params: { id: @project.id }
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
            get :invite, params: { id: @project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
      end

      it '302レスポンスを返すこと' do
        get :invite, params: { id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :invite, params: { id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
