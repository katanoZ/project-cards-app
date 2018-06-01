require 'rails_helper'

RSpec.describe ColumnsController, type: :controller do
  describe '#create' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
        end

        context '有効な属性値の場合' do
          before do
            @column_params = FactoryBot.attributes_for(:column)
          end

          it 'カラムが作成できること' do
            sign_in @user
            expect {
              post :create, params: { project_id: @project.id, column: @column_params }
            }.to change(@project.columns, :count).by(1)
          end

          it 'プロジェクト画面にリダイレクトすること' do
            sign_in @user
            post :create, params: { project_id: @project.id, column: @column_params }
            expect(response).to redirect_to project_path(@project)
          end
        end

        context '無効な属性値の場合' do
          before do
            @column_params = FactoryBot.attributes_for(:column, :invalid)
          end

          it 'カラムが作成できないこと' do
            sign_in @user
            expect {
              post :create, params: { project_id: @project.id, column: @column_params }
            }.to change(@project.columns, :count).by(0)
          end

          it 'テンプレートを再表示すること' do
            sign_in @user
            post :create, params: { project_id: @project.id, column: @column_params }
            expect(response).to render_template :new
          end
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column_params = FactoryBot.attributes_for(:column)
          sign_in @user
          expect {
            post :create, params: { project_id: project.id, column: column_params }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column_params = FactoryBot.attributes_for(:column)
      end

      it '302レスポンスを返すこと' do
        post :create, params: { project_id: @project.id, column: @column_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        post :create, params: { project_id: @project.id, column: @column_params }
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
          @project = FactoryBot.create(:project, user: @user)
          @column = FactoryBot.create(:column, project: @project, name: '古い名前')
        end

        context '有効な属性値の場合' do
          before do
            @column_params = FactoryBot.attributes_for(:column, name: '新しい名前')
          end

          it 'カラムが更新できること' do
            sign_in @user
            patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
            expect(@column.reload.name).to eq '新しい名前'
          end

          it 'プロジェクト画面にリダイレクトすること' do
            sign_in @user
            patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
            expect(response).to redirect_to project_path(@project)
          end
        end

        context '無効な属性値の場合' do
          before do
            @column_params = FactoryBot.attributes_for(:column, :invalid)
          end

          it 'カラムが更新できないこと' do
            sign_in @user
            patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
            expect(@column.reload.name).to eq '古い名前'
          end

          it 'テンプレートを再表示すること' do
            sign_in @user
            patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
            expect(response).to render_template :edit
          end
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          column_params = FactoryBot.attributes_for(:column)

          sign_in @user
          expect {
            patch :update, params: { id: column.id, project_id: project.id, column: column_params }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
      end

      it '302レスポンスを返すこと' do
        patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        patch :update, params: { id: @column.id, project_id: @project.id, column: @column_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
          @column = FactoryBot.create(:column, project: @project)
        end

        it 'カラムが削除できること' do
          sign_in @user
          expect {
            delete :destroy, params: { id: @column.id, project_id: @project.id }
          }.to change(@project.columns, :count).by(-1)
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          delete :destroy, params: { id: @column.id, project_id: @project.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)

          sign_in @user
          expect {
            delete :destroy, params: { id: column.id, project_id: project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
      end

      it '302レスポンスを返すこと' do
        delete :destroy, params: { id: @column.id, project_id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        delete :destroy, params: { id: @column.id, project_id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#previous' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
          columns = FactoryBot.create_list(:column, 5, project: @project)
          @column = columns.last
        end

        it 'カラムが移動できること' do
          sign_in @user
          past_position = @column.position
          get :previous, params: { id: @column.id, project_id: @project.id }
          expect(@column.reload.position).to eq(past_position - 1)
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          get :previous, params: { id: @column.id, project_id: @project.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)

          sign_in @user
          expect {
            get :previous, params: { id: column.id, project_id: project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
      end

      it '302レスポンスを返すこと' do
        get :previous, params: { id: @column.id, project_id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :previous, params: { id: @column.id, project_id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#next' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
          columns = FactoryBot.create_list(:column, 5, project: @project)
          @column = columns.first
        end

        it 'カラムが移動できること' do
          sign_in @user
          past_position = @column.position
          get :next, params: { id: @column.id, project_id: @project.id }
          expect(@column.reload.position).to eq(past_position + 1)
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          get :next, params: { id: @column.id, project_id: @project.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)

          sign_in @user
          expect {
            get :next, params: { id: column.id, project_id: project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
      end

      it '302レスポンスを返すこと' do
        get :next, params: { id: @column.id, project_id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :next, params: { id: @column.id, project_id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
