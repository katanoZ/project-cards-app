require 'rails_helper'

RSpec.feature "Cards", type: :feature do
  before do
    facebook_login_setup
    visit auth_path(:facebook)

    click_link 'プロジェクトを作成する'
    fill_in 'プロジェクト名', with: '社内用アプリ開発'
    fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
    click_button '作成'

    click_link '社内用アプリ開発'
    click_link 'プロジェクト詳細'
  end

  describe 'カードの作成、編集、削除' do
    before do
      click_link 'カラムを追加'
      fill_in 'カラム名', with: '要求定義'
      click_button '作成'

      @column = Column.find_by(name: '要求定義')
    end

    scenario 'ユーザがプロジェクト詳細ページからカードを作成をする' do
      expect {
        click_link 'カードを追加'
        fill_in 'カード名', with: '初回ヒアリング'
        click_button '作成'

        expect(page).to have_content 'カードを作成しました'
        expect(page).to have_content '初回ヒアリング'
      }.to change(@column.cards, :count).by(1)
    end

    context '編集、削除' do
      before do
        click_link 'カードを追加'
        fill_in 'カード名', with: '初回ヒアリング'
        click_button '作成'
      end

      scenario 'ユーザがプロジェクト詳細ページからカードを編集する' do
        expect {
          click_link '初回ヒアリング'
          fill_in 'カード名', with: '録音準備'
          click_button '編集'

          expect(page).to have_content 'カードを更新しました'
          expect(page).to have_content '録音準備'
        }.to change(@column.cards, :count).by(0)
      end

      scenario 'ユーザがプロジェクト詳細ページからカードを削除する', js: true do
        expect {
          click_link '初回ヒアリング'
          click_link '削除'
          page.driver.browser.switch_to.alert.accept

          expect(page).to have_content 'カードを削除しました'
        }.to change(@column.cards, :count).by(-1)
      end
    end
  end

  describe 'カードの移動' do
    before do
      project = Project.find_by(name: '社内用アプリ開発')

      # カラムとカード作成
      click_link 'カラムを追加'
      fill_in 'カラム名', with: 'カラム１'
      click_button '作成'

      click_link 'カラムを追加'
      fill_in 'カラム名', with: 'カラム２'
      click_button '作成'

      @column1 = project.columns.find_by(name: 'カラム１')
      @column2 = project.columns.find_by(name: 'カラム２')

      click_link 'カードを追加', href: new_project_column_card_path(project, @column1)
      fill_in 'カード名', with: 'カード１−１'
      click_button '作成'

      click_link 'カードを追加', href: new_project_column_card_path(project, @column1)
      fill_in 'カード名', with: 'カード１−２'
      click_button '作成'

      click_link 'カードを追加', href: new_project_column_card_path(project, @column2)
      fill_in 'カード名', with: 'カード２−１'
      click_button '作成'

      @card1_1 = project.cards.find_by(name: 'カード１−１')
    end

    scenario 'ユーザがプロジェクト詳細ページからカードを移動する' do
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
end
