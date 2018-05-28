require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'name' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:project)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      project = FactoryBot.build(:project, name: nil)
      project.valid?
      expect(project.errors[:name]).to include('を入力してください')
    end

    it '名前が違えば有効な状態であること' do
      project1 = FactoryBot.create(:project, name: '社内開発')
      project2 = FactoryBot.build(:project, name: '受託開発')
      expect(project2).to be_valid
    end

    it '名前が同じであれば無効な状態であること' do
      project1 = FactoryBot.create(:project, name: '受託開発')
      project2 = FactoryBot.build(:project, name: '受託開発')
      project2.valid?
      expect(project2.errors[:name]).to include('はすでに存在します')
    end

    it '名前が140文字であれば有効な状態であること' do
      project = FactoryBot.build(:project, :name_140)
      expect(project).to be_valid
    end

    it '名前が141文字であれば無効な状態であること' do
      project = FactoryBot.build(:project, :name_141)
      project.valid?
      expect(project.errors[:name]).to include('は140文字以内で入力してください')
    end
  end

  describe 'summary' do
    it '概要が300文字であれば有効な状態であること' do
      project = FactoryBot.build(:project, :summary_300)
      expect(project).to be_valid
    end

    it '概要が301文字であれば無効な状態であること' do
      project = FactoryBot.build(:project, :summary_301)
      project.valid?
      expect(project.errors[:summary]).to include('は300文字以内で入力してください')
    end
  end
end
