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
end
