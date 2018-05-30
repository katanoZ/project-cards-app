require 'rails_helper'

RSpec.feature "Columns", type: :feature do
  before do
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

  describe 'カラムの作成、編集、削除' do
    scenario 'ユーザがプロジェクト詳細ページからカラムの作成をする' do
      expect {
        click_link 'カラムを追加'
        fill_in 'カラム名', with: '要求定義'
        click_button '作成'

        expect(page).to have_content 'カラムを作成しました'
        expect(page).to have_content '要求定義'
      }.to change(@project.columns, :count).by(1)
    end

    context '編集、削除' do
      before do
        click_link 'カラムを追加'
        fill_in 'カラム名', with: '要求定義'
        click_button '作成'
      end

      scenario 'ユーザがプロジェクト詳細ページからカラムを編集する' do
        expect {
          click_link '要求定義'
          fill_in 'カラム名', with: '事前準備'
          click_button '編集'

          expect(page).to have_content 'カラムを更新しました'
          expect(page).to have_content '事前準備'
        }.to change(@project.columns, :count).by(0)
      end

      scenario 'ユーザがプロジェクト詳細ページからカラムを削除する', js: true do
        expect {
          click_link '要求定義'
          click_link '削除'
          page.driver.browser.switch_to.alert.accept

          expect(page).to have_content 'カラムを削除しました'
        }.to change(@project.columns, :count).by(-1)
      end
    end
  end

  describe 'カラムの移動' do
    before do
      click_link 'カラムを追加'
      fill_in 'カラム名', with: '最初に作成'
      click_button '作成'

      click_link 'カラムを追加'
      fill_in 'カラム名', with: '次に作成'
      click_button '作成'

      @first_column = Column.find_by(name: '最初に作成')
    end

    scenario 'ユーザがプロジェクト詳細ページからカラムを移動する' do
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
end
