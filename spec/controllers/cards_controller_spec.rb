require 'rails_helper'

RSpec.describe CardsController, type: :controller do
  describe '#create' do
    before do
      @user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
          @column = FactoryBot.create(:column, project: @project)
        end

        context '有効な属性値の場合' do
          before do
            @card_params = FactoryBot.attributes_for(:card, project: @project, assignee_id: @user.id)
          end

          it 'カードが作成できること' do
            sign_in @user
            expect {
              post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
            }.to change(@column.cards, :count).by(1)
          end

          it 'プロジェクト画面にリダイレクトすること' do
            sign_in @user
            post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
            expect(response).to redirect_to project_path(@project)
          end
        end

        context '無効な属性値の場合' do
          before do
            @card_params = FactoryBot.attributes_for(:card, :invalid, project: @project, assignee_id: @user.id)
          end

          it 'カードが作成できないこと' do
            sign_in @user
            expect {
              post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
            }.to change(@column.cards, :count).by(0)
          end

          it 'テンプレートを再表示すること' do
            sign_in @user
            post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
            expect(response).to render_template :new
          end
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          card_params = FactoryBot.attributes_for(:card, project: project, assignee_id: @user.id)

          sign_in @user
          expect {
            post :create, params: { project_id: project.id, column_id: column.id, card: card_params }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
        @card_params = FactoryBot.attributes_for(:card, project: @project, assignee_id: @user.id)
      end

      it '302レスポンスを返すこと' do
        post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        post :create, params: { project_id: @project.id, column_id: @column.id, card: @card_params }
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
          @column = FactoryBot.create(:column, project: @project)
          @card = FactoryBot.create(:card, project: @project, column: @column, name: '古い名前')
        end

        context '有効な属性値の場合' do
          before do
            @card_params = FactoryBot.attributes_for(:card, project: @project, assignee_id: @user.id, name: '新しい名前')
          end

          it 'カードが更新できること' do
            sign_in @user
            patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }

            expect(@card.reload.name).to eq '新しい名前'
          end

          it 'プロジェクト画面にリダイレクトすること' do
            sign_in @user
            patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }
            expect(response).to redirect_to project_path(@project)
          end
        end

        context '無効な属性値の場合' do
          before do
            @card_params = FactoryBot.attributes_for(:card, :invalid, project: @project, assignee_id: @user.id)
          end

          it 'カードが更新できないこと' do
            sign_in @user
            patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }
            expect(@card.reload.name).to eq '古い名前'
          end

          it 'テンプレートを再表示すること' do
            sign_in @user
            patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }
            expect(response).to render_template :edit
          end
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          card = FactoryBot.create(:card, project: project, column: column)
          card_params = FactoryBot.attributes_for(:card, project: project, assignee_id: @user.id)

          sign_in @user
          expect {
            patch :update, params: { id: card.id, project_id: project.id, column_id: column.id, card: card_params }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      it '302レスポンスを返すこと' do
        patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        patch :update, params: { id: @card.id, project_id: @project.id, column_id: @column.id, card: @card_params }
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
          @card = FactoryBot.create(:card, project: @project, column: @column)
        end

        it 'カードが削除できること' do
          sign_in @user
          expect {
            delete :destroy, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
          }.to change(@column.cards, :count).by(-1)
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          delete :destroy, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          card = FactoryBot.create(:card, project: project, column: column)

          sign_in @user
          expect {
            delete :destroy, params: { id: card.id, project_id: project.id, column_id: column.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      it '302レスポンスを返すこと' do
        delete :destroy, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        delete :destroy, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
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
          columns = FactoryBot.create_list(:column, 7, project: @project)
          @column = columns.last
          cards = FactoryBot.create_list(:card, 6, project: @project, column: @column)
          @card = cards.last
        end

        it 'カードが移動できること' do
          sign_in @user
          past_column_position = @column.position
          get :previous, params: { id: @card.id, project_id: @project.id, column_id: @column.id }

          expect(@card.reload.column.position).to eq(past_column_position - 1) #カードは一つ前のカラムに移動
          expect(@card.reload.position).to eq(1) #カードはカラムの先頭位置に移動
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          get :previous, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          card = FactoryBot.create(:card, project: project, column: column)

          sign_in @user
          expect {
            get :previous, params: { id: card.id, project_id: project.id, column_id: column.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      it '302レスポンスを返すこと' do
        get :previous, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        get :previous, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
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
          columns = FactoryBot.create_list(:column, 7, project: @project)
          @column = columns.first
          cards = FactoryBot.create_list(:card, 6, project: @project, column: @column)
          @card = cards.first
        end

        it 'カードが移動できること' do
          sign_in @user
          past_column_position = @column.position
          get :next, params: { id: @card.id, project_id: @project.id, column_id: @column.id }

          expect(@card.reload.column.position).to eq(past_column_position + 1) #カードは一つ後ろのカラムに移動
          expect(@card.reload.position).to eq(1) #カードはカラムの先頭位置に移動
        end

        it 'プロジェクト画面にリダイレクトすること' do
          sign_in @user
          get :next, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          project = FactoryBot.create(:project)
          column = FactoryBot.create(:column, project: project)
          card = FactoryBot.create(:card, project: project, column: column)

          sign_in @user
          expect {
            get :next, params: { id: card.id, project_id: project.id, column_id: column.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
        @column = FactoryBot.create(:column, project: @project)
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      it '302レスポンスを返すこと' do
        get :next, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
        expect(response).to have_http_status '302'
      end
      it 'ログイン画面にリダイレクトすること' do
        get :next, params: { id: @card.id, project_id: @project.id, column_id: @column.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
