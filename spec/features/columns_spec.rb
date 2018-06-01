require 'rails_helper'

RSpec.feature "Columns", type: :feature do
  feature 'ユーザがプロジェクト詳細ページからカラムの作成をする' do
    context '権限がある場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')

        click_link '社内用アプリ開発'
        click_link 'プロジェクト詳細'
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カラムが作成できること' do
          expect {
            click_link 'カラムを追加'
            fill_in 'カラム名', with: '要求定義'
            click_button '作成'

            expect(page).to have_content 'カラムを作成しました'
            expect(page).to have_content '要求定義'
          }.to change(@project.columns, :count).by(1)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario 'カラム作成画面に直接URL入力して遷移しようとすると、ログイン画面に移動すること' do
          visit new_project_column_path(@project)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカラム作成しようとすると、ログイン画面に移動してカラム作成できないこと' do
          column_params = FactoryBot.attributes_for(:column)
          page.driver.submit :post, project_columns_path(@project), column_params
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

      scenario 'カラム作成画面に直接URL入力して遷移しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit new_project_column_path(@project)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカラム作成しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          column_params = FactoryBot.attributes_for(:column)
          page.driver.submit :post, project_columns_path(@project), column_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカラムを編集する' do
    context '権限がある場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        click_link '社内用アプリ開発'
        click_link 'プロジェクト詳細'

        click_link 'カラムを追加'
        fill_in 'カラム名', with: '要求定義'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')
        @column = @project.columns.find_by(name: '要求定義')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カラムが編集できること' do
          expect {
            click_link '要求定義'
            fill_in 'カラム名', with: '事前準備'
            click_button '編集'

            expect(page).to have_content 'カラムを更新しました'
            expect(page).to have_content '事前準備'
          }.to change(@project.columns, :count).by(0)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario 'カラム編集画面に直接URL入力して遷移しようとすると、ログイン画面に移動すること' do
          visit edit_project_column_path(@project, @column)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカラム編集しようとすると、ログイン画面に移動してカラム作成できないこと' do
          column_params = FactoryBot.attributes_for(:column)
          page.driver.submit :patch, project_column_path(@project, @column), column: column_params
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
        @column = FactoryBot.create(:column, project: @project)
      end

      scenario 'カラム編集画面に直接URL入力して遷移しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit edit_project_column_path(@project, @column)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカラム編集しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        column_params = FactoryBot.attributes_for(:column)

        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          page.driver.submit :patch, project_column_path(@project, @column), column: column_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカラムを削除する' do
    context '権限がある場合' do
      background do
        facebook_login_setup
        visit auth_path(:facebook)

        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        click_link '社内用アプリ開発'
        click_link 'プロジェクト詳細'

        click_link 'カラムを追加'
        fill_in 'カラム名', with: '要求定義'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')
        @column = Column.find_by(name: '要求定義')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カラムを削除できること', js: true do
          expect {
            click_link '要求定義'
            click_link '削除'
            page.driver.browser.switch_to.alert.accept

            expect(page).to have_content 'カラムを削除しました'
          }.to change(@project.columns, :count).by(-1)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario '直接URL入力してカラム削除しようとすると、ログイン画面に移動してカラム作成できないこと' do
          page.driver.submit :delete, project_column_path(@project, @column), {}
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
        @column = FactoryBot.create(:column, project: @project)
      end

      scenario '直接URL入力してカラム削除しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          page.driver.submit :delete, project_column_path(@project, @column), {}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカラムを移動する' do
    context '権限がある場合' do
      background do
        facebook_login_setup

        visit auth_path(:facebook)
        click_link 'プロジェクトを作成する'
        fill_in 'プロジェクト名', with: '社内用アプリ開発'
        fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
        click_button '作成'

        @project = Project.find_by(name: '社内用アプリ開発')

        click_link '社内用アプリ開発'
        click_link 'プロジェクト詳細'

        click_link 'カラムを追加'
        fill_in 'カラム名', with: '最初に作成'
        click_button '作成'

        click_link 'カラムを追加'
        fill_in 'カラム名', with: '次に作成'
        click_button '作成'

        @first_column = @project.columns.find_by(name: '最初に作成')
        @second_column = @project.columns.find_by(name: '次に作成')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カラムの移動ができること' do
          # 先頭の位置にある「最初に作成」カラムを右に移動
          within first('.card-header') do
            # [←][カラム名][→]
            all('a')[2].click
          end

          #「最初に作成」カラムが最後に移動していること
          expect(@project.columns.order(position: :asc).last).to eq @first_column

          # 最後の位置にある「最初に作成」カラムを左に移動
          within all('.card-header').last do
            # [←][カラム名][→]
            all('a')[0].click
          end

          #「最初に作成」カラムが先頭に移動していること
          expect(@project.columns.order(position: :asc).first).to eq @first_column
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario '直接URL入力してカラム右移動しようとすると、ログインページに移動してカラム移動できないこと' do
          visit next_project_column_path(@project, @first_column)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカラム左移動しようとすると、ログインページに移動してカラム移動できないこと' do
          visit previous_project_column_path(@project, @second_column)
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
        @column1 = FactoryBot.create(:column, project: @project)
        @column2 = FactoryBot.create(:column, project: @project)
      end

      scenario '直接URL入力してカラム右移動しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit next_project_column_path(@project, @column1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカラム左移動しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit previous_project_column_path(@project, @column2)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
