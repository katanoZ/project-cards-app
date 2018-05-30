require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  before do
    facebook_login_setup
    visit auth_path(:facebook)
  end

  scenario 'ユーザがトップページからプロジェクトを作成する' do
    click_link 'プロジェクトを作成する'
    expect {
      fill_in 'プロジェクト名', with: '社内用アプリ開発'
      fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
      click_button '作成'

      expect(page).to have_content 'プロジェクトを作成しました'
      expect(page).to have_content '社内用アプリ開発'
    }.to change(Project, :count).by(1)
  end

  scenario 'ユーザがプロジェクト編集ページから編集する' do
    click_link 'プロジェクトを作成する'
    fill_in 'プロジェクト名', with: '社内用アプリ開発'
    fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
    click_button '作成'

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

  scenario 'ユーザがプロジェクト編集ページから削除する', js: true do
    click_link 'プロジェクトを作成する'
    fill_in 'プロジェクト名', with: '社内用アプリ開発'
    fill_in '概要', with: '社内で使用するアプリを開発するプロジェクトです。'
    click_button '作成'

    click_link '社内用アプリ開発'
    click_link 'プロジェクト編集'
    expect {
      click_link '削除'
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content 'プロジェクトを削除しました'
    }.to change(Project, :count).by(-1)
  end
end
