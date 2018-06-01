require 'rails_helper'

RSpec.describe Column, type: :model do
  describe 'name' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:column)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      column = FactoryBot.build(:column, name: nil)
      column.valid?
      expect(column.errors[:name]).to include('を入力してください')
    end

    it '名前が40文字であれば有効な状態であること' do
      column = FactoryBot.build(:column, :name_40)
      expect(column).to be_valid
    end

    it '名前が41文字であれば無効な状態であること' do
      column = FactoryBot.build(:column, :name_41)
      column.valid?
      expect(column.errors[:name]).to include('は40文字以内で入力してください')
    end

    context 'プロジェクトと組み合わせた場合' do
      before do
        @project = FactoryBot.create(:project)
        @column1 = FactoryBot.create(:column, project: @project, name: '営業用タスク')
      end

      it '同じプロジェクトの中で違う名前であれば有効な状態であること' do
        column2 = FactoryBot.build(:column, project: @project, name: '人事用タスク')
        expect(column2).to be_valid
      end

      it '同じプロジェクトの中で同じ名前であれば無効な状態であること' do
        column2 = FactoryBot.build(:column, project: @project, name: '営業用タスク')
        column2.valid?
        expect(column2.errors[:name]).to include('はすでに存在します')
      end

      it '違うプロジェクトの中で同じ名前であれば有効な状態であること' do
        other_project = FactoryBot.create(:project)
        column2 = FactoryBot.build(:column, project: other_project, name: '営業用タスク')
        expect(column2).to be_valid
      end
    end
  end
end
