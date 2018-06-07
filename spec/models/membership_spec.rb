require 'rails_helper'

RSpec.describe Membership, type: :model do
  let(:membership) { FactoryBot.create(:membership) }

  describe 'project_idのバリデーション' do
    it '同じプロジェクトと違うユーザの組み合わせであれば有効な状態であること' do
      other_user = FactoryBot.create(:user)
      new_membership = FactoryBot.build(:membership, project: membership.project, user: other_user)
      expect(new_membership).to be_valid
    end

    it '違うプロジェクトと同じユーザの組み合わせであれば有効な状態であること' do
      other_project = FactoryBot.create(:project)
      new_membership = FactoryBot.build(:membership, project: other_project, user: membership.user)
      expect(new_membership).to be_valid
    end

    it '同じプロジェクトと同じユーザの組み合わせであれば無効な状態であること' do
      new_membership = FactoryBot.build(:membership, project: membership.project, user: membership.user)
      new_membership.valid?
      expect(new_membership.errors[:project_id]).to include('はすでに存在します')
    end
  end

  describe '#join!' do
    it 'joinがfalseの場合は実行するとtrueになること' do
      expect { membership.join! }.to change { membership.join }.from(be_falsey).to(be_truthy)
    end

    it 'joinがtrueの場合は実行するとtrueであること' do
      membership = FactoryBot.create(:membership, join: true)
      membership.join!
      expect(membership.join).to be_truthy
    end
  end

  describe '#excludes_host_user' do
    let(:project) { FactoryBot.create(:project) }

    it 'ユーザにprojectのホストユーザ以外が指定されると保存が成功すること' do
      user = FactoryBot.create(:user)
      membership = FactoryBot.build(:membership, project: project, user: user)
      expect(membership.save).to be_truthy
    end

    it 'ユーザにprojectのホストユーザが指定されると保存が失敗すること' do
      membership = FactoryBot.build(:membership, project: project, user: project.user)
      expect(membership.save).to be_falsey
    end
  end
end
