require 'rails_helper'

RSpec.describe MembershipsController, type: :controller do
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

  describe '#create' do
    before do
      @user = FactoryBot.create(:user)
      @other_user = FactoryBot.create(:user)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        before do
          @project = FactoryBot.create(:project, user: @user)
        end

        it '招待を作成できること' do
          sign_in @user
          expect {
            post :create, params: { user_id: @other_user.id, project_id: @project.id }
          }.to change(@project.memberships.where(join: false), :count).by(1)
        end

        it 'プロジェクトの画面にリダイレクトすること' do
          sign_in @user
          post :create, params: { user_id: @other_user.id, project_id: @project.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        before do
          @project = FactoryBot.create(:project)
        end

        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          sign_in @user
          expect {
            post :create, params: { user_id: @other_user.id, project_id: @project.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      before do
        @project = FactoryBot.create(:project, user: @user)
      end

      it '302レスポンスを返すこと' do
        post :create, params: { user_id: @other_user.id, project_id: @project.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        post :create, params: { user_id: @other_user.id, project_id: @project.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#update' do
    before do
      @invite_user = FactoryBot.create(:user)
      @project = FactoryBot.create(:project)
      @membership = FactoryBot.create(:membership, user: @invite_user, project: @project)
    end

    context 'ログインしている場合' do
      context '権限のあるユーザの場合' do
        it 'プロジェクトに参加すること' do
          sign_in @invite_user
          patch :update, params: { id: @membership.id }
          membership = @invite_user.memberships.find_by(project: @project)
          expect(membership.join).to eq true
        end

        it 'プロジェクトの画面にリダイレクトすること' do
          sign_in @invite_user
          patch :update, params: { id: @membership.id }
          expect(response).to redirect_to project_path(@project)
        end
      end

      context '権限のないユーザの場合' do
        it 'ActiveRecord::RecordNotFound例外を返すこと' do
          user = FactoryBot.create(:user)
          sign_in user
          expect {
            patch :update, params: { id: @membership.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'ログインしていない場合' do
      it '302レスポンスを返すこと' do
        patch :update, params: { id: @membership.id }
        expect(response).to have_http_status '302'
      end

      it 'ログイン画面にリダイレクトすること' do
        patch :update, params: { id: @membership.id }
        expect(response).to redirect_to login_path
      end
    end
  end
end
