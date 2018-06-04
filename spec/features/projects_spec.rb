require 'rails_helper'

# scenario中のActiveRecord::RecordNotFoundエラーを確認するためには、
# config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施する

RSpec.feature "Projects", type: :feature do
  feature 'ユーザがトップページからプロジェクトを作成する' do
    context 'ログイン済みの場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)
      end

      scenario 'プロジェクトを作成できること' do
        click_link 'プロジェクトを作成する'
        expect {
          fill_in 'プロジェクト名', with: '社内用アプリ開発'
          fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
          click_button '作成'

          expect(page).to have_content 'プロジェクトを作成しました'
          expect(page).to have_content '社内用アプリ開発'
        }.to change(Project, :count).by(1)
      end
    end

    context '未ログインの場合' do
      scenario 'トップページに遷移するとログインページに移動して、プロジェクトが作成できないこと' do
        visit root_path
        expect(page).to have_content 'ログインしてください'
        expect(current_path).to eq login_path
      end
    end
  end

  feature 'ユーザがプロジェクト編集ページから編集する' do
    context '権限がある場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'プロジェクトが編集できること' do
          click_link '社内用アプリ開発'
          click_link 'プロジェクト編集'
          expect {
            fill_in 'プロジェクト名', with: '営業用アプリ開発'
            fill_in '概要', with: '営業用のアプリを開発するプロジェクトです。'
            click_button '編集'

            expect(page).to have_content 'プロジェクトを更新しました'
            expect(page).to have_content '営業用アプリ開発'
          }.to change(Project, :count).by(0)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario 'プロジェクト編集画面に直接URL入力して遷移しようとすると、ログイン画面に移動すること' do
          visit edit_project_path(@project)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力して編集しようとするとログインページに移動して、プロジェクトが編集できないこと' do
          project_params = FactoryBot.attributes_for(:project)
          page.driver.submit :patch, project_path(@project), column: project_params
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end
      end
    end

    context '権限がない場合（ログインして確認）' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        @project = FactoryBot.create(:project, name: '権限なしプロジェクト')
      end

      scenario 'トップページに該当プロジェクトは表示されているが、プロジェクト編集用のリンクがないこと' do
        visit root_path
        expect(page).to have_content '権限なしプロジェクト'
        expect(page).not_to have_selector 'a', text: '権限なしプロジェクト'
        expect(page).not_to have_content 'プロジェクト編集'
      end

      # 実施にはconfigの設定が必要
      scenario 'プロジェクト編集画面に直接URL入力して遷移しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        expect {
          visit edit_project_path(@project)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      # 実施にはconfigの設定が必要
      scenario '直接URL入力して編集しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        expect {
          project_params = FactoryBot.attributes_for(:project)
          page.driver.submit :patch, project_path(@project), column: project_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト編集ページから削除する' do
    context '権限がある場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'プロジェクトが削除できること', js: true do
          click_link '社内用アプリ開発'
          click_link 'プロジェクト編集'
          expect {
            click_link '削除'
            page.driver.browser.switch_to.alert.accept

            expect(page).to have_content 'プロジェクトを削除しました'
          }.to change(Project, :count).by(-1)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario '直接URL入力して削除しようとするとログインページに移動して、プロジェクトが削除できないこと' do
          page.driver.submit :delete, project_path(@project), {}
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end
      end
    end

    context '権限がない場合（ログインして確認）' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        @project = FactoryBot.create(:project)
      end

      # 実施にはconfigの設定が必要
      scenario '直接URL入力して削除しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        expect {
          page.driver.submit :delete, project_path(@project), {}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
