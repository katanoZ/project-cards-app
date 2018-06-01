require 'rails_helper'

RSpec.feature "Cards", type: :feature do
  feature 'ユーザがプロジェクト詳細ページからカードを作成をする' do
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
        scenario 'カードが作成できること' do
          expect {
            click_link 'カードを追加'
            fill_in 'カード名', with: '初回ヒアリング'
            click_button '作成'

            expect(page).to have_content 'カードを作成しました'
            expect(page).to have_content '初回ヒアリング'
          }.to change(@column.cards, :count).by(1)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario 'カード作成画面に直接URL入力して遷移しようとすると、ログイン画面に移動すること' do
          visit new_project_column_card_path(@project, @column)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカード作成しようとすると、ログイン画面に移動してカラム作成できないこと' do
          card_params = FactoryBot.attributes_for(:card, project: @project)
          page.driver.submit :post, project_column_cards_path(@project, @column), card_params
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

      scenario 'カード作成画面に直接URL入力して遷移しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit new_project_column_card_path(@project, @column)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカード作成しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          card_params = FactoryBot.attributes_for(:card, project: @project)
          page.driver.submit :post, project_column_cards_path(@project, @column), card_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカードを編集する' do
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

        click_link 'カードを追加'
        fill_in 'カード名', with: '初回ヒアリング'
        click_button '作成'
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カードが編集できること' do
          expect {
            click_link '初回ヒアリング'
            fill_in 'カード名', with: '録音準備'
            click_button '編集'

            expect(page).to have_content 'カードを更新しました'
            expect(page).to have_content '録音準備'
          }.to change(@column.cards, :count).by(0)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'

          @card = @project.cards.find_by(name: '初回ヒアリング')
        end

        scenario 'カード編集画面に直接URL入力して遷移しようとすると、ログイン画面に移動すること' do
          visit edit_project_column_card_path(@project, @column, @card)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカード編集しようとすると、ログイン画面に移動してカード作成できないこと' do
          card_params = FactoryBot.attributes_for(:card, project: @project)
          page.driver.submit :patch, project_column_card_path(@project, @column, @card), card_params
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
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      scenario 'カード編集画面に直接URL入力して遷移しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit edit_project_column_card_path(@project, @column, @card)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカード編集しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          card_params = FactoryBot.attributes_for(:card, project: @project)
          page.driver.submit :patch, project_column_card_path(@project, @column, @card), card_params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカードを削除する' do
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

        click_link 'カードを追加'
        fill_in 'カード名', with: '初回ヒアリング'
        click_button '作成'
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カードを削除できること', js: true do
          expect {
            click_link '初回ヒアリング'
            click_link '削除'
            page.driver.browser.switch_to.alert.accept

            expect(page).to have_content 'カードを削除しました'
          }.to change(@column.cards, :count).by(-1)
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'

          @card = @project.cards.find_by(name: '初回ヒアリング')
        end

        scenario '直接URL入力してカラム削除しようとすると、ログイン画面に移動してカラム作成できないこと' do
          page.driver.submit :delete, project_column_card_path(@project, @column, @card), {}
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
        @card = FactoryBot.create(:card, project: @project, column: @column)
      end

      scenario '直接URL入力してカード削除しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          page.driver.submit :delete, project_column_card_path(@project, @column, @card), {}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  feature 'ユーザがプロジェクト詳細ページからカードを移動する' do
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

        @project = Project.find_by(name: '社内用アプリ開発')

        # カラムとカード作成
        click_link 'カラムを追加'
        fill_in 'カラム名', with: 'カラム１'
        click_button '作成'

        click_link 'カラムを追加'
        fill_in 'カラム名', with: 'カラム２'
        click_button '作成'

        @column1 = @project.columns.find_by(name: 'カラム１')
        @column2 = @project.columns.find_by(name: 'カラム２')

        click_link 'カードを追加', href: new_project_column_card_path(@project, @column1)
        fill_in 'カード名', with: 'カード１−１'
        click_button '作成'

        click_link 'カードを追加', href: new_project_column_card_path(@project, @column1)
        fill_in 'カード名', with: 'カード１−２'
        click_button '作成'

        click_link 'カードを追加', href: new_project_column_card_path(@project, @column2)
        fill_in 'カード名', with: 'カード２−１'
        click_button '作成'

        @card1_1 = @project.cards.find_by(name: 'カード１−１')
        @card2_1 = @project.cards.find_by(name: 'カード２−１')
      end

      context '権限があり、ログイン済みの場合' do
        scenario 'カードの移動ができること' do
          # カード１−１の右移動をクリック
          find(:xpath, '/html/body/div[2]/div[3]/div[1]/div/div[2]/div[2]/div/div[1]/div[3]/a').click

          #カード１−１がカラム２の先頭に移動していること
          expect(@column2.cards.order(position: :desc).first).to eq @card1_1

          # カード１−１の左移動をクリック
          find(:xpath, '/html/body/div[2]/div[2]/div[2]/div/div[2]/div[1]/div/div[1]/div[1]/a').click

          # カード１−１がカラム１の先頭に移動していること
          expect(@column1.cards.order(position: :desc).first).to eq @card1_1
        end
      end

      context '権限はあるが、未ログインの場合' do
        background do
          visit mypage_path
          click_link 'ログアウト'
        end

        scenario '直接URL入力してカラム右移動しようとすると、ログインページに移動してカラム移動できないこと' do
          visit next_project_column_card_path(@project, @column1, @card1_1)
          expect(page).to have_content 'ログインしてください'
          expect(current_path).to eq login_path
        end

        scenario '直接URL入力してカラム左移動しようとすると、ログインページに移動してカラム移動できないこと' do
          visit previous_project_column_card_path(@project, @column2, @card2_1)
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
        @card1 = FactoryBot.create(:card, project: @project, column: @column1)
        @card2 = FactoryBot.create(:card, project: @project, column: @column2)
      end

      scenario '直接URL入力してカラム右移動しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit next_project_column_card_path(@project, @column1, @card1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario '直接URL入力してカラム左移動しようとすると、ActiveRecord::RecordNotFoundエラーになること' do
        # config/environments/test.rbでconfig.consider_all_requests_local = falseに設定して実施
        expect {
          visit previous_project_column_card_path(@project, @column2, @card2)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
