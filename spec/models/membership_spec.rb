require 'rails_helper'

RSpec.describe Membership, type: :model do
  context 'プロジェクトとユーザを組み合わせた場合' do
    before do
      @project = FactoryBot.create(:project)
      @user = FactoryBot.create(:user)
      @membership = FactoryBot.create(:membership, project: @project, user: @user)
    end

    it '同じプロジェクトと違うユーザの組み合わせであれば有効な状態であること' do
      other_user = FactoryBot.create(:user)
      membership2 = FactoryBot.build(:membership, project: @project, user: other_user)
      expect(membership2).to be_valid
    end

    it '同じプロジェクトと同じユーザの組み合わせであれば無効な状態であること' do
      membership2 = FactoryBot.build(:membership, project: @project, user: @user)
      membership2.valid?
      expect(membership2.errors[:project_id]).to include('はすでに存在します')
    end

    it '違うプロジェクトと同じユーザの組み合わせであれば有効な状態であること' do
      other_project = FactoryBot.create(:project)
      membership2 = FactoryBot.build(:membership, project: other_project, user: @user)
      expect(membership2).to be_valid
    end
  end

  describe 'join!' do
    it 'joinがfalseの場合は実行するとtrueになること' do
      membership = FactoryBot.create(:membership)
      membership.join!
      expect(membership.join).to eq true
    end

    it 'joinがtrueの場合は実行するとtrueのままであること' do
      membership = FactoryBot.create(:membership, join: true)
      membership.join!
      expect(membership.join).to eq true
    end
  end

  describe 'excludes_host_user' do
    before do
      @project = FactoryBot.create(:project)
    end

    it 'ユーザにprojectのホストユーザ以外が指定されると保存が成功すること' do
      user = FactoryBot.create(:user)
      membership = FactoryBot.build(:membership, project: @project, user: user)
      expect(membership.save).to eq true
    end

    it 'ユーザにprojectのホストユーザが指定されると保存が失敗すること' do
      membership = FactoryBot.build(:membership, project: @project, user: @project.user)
      expect(membership.save).to eq false
    end
  end
end
