require 'rails_helper'

RSpec.describe Column, type: :model do
  describe 'nameのバリデーション' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:column)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      column = FactoryBot.build(:column, name: nil)
      column.valid?
      expect(column.errors[:name]).to include('を入力してください')
    end

    it '名前が40文字であれば有効な状態であること' do
      column = FactoryBot.build(:column, name: Faker::Lorem.characters(40))
      expect(column).to be_valid
    end

    it '名前が41文字であれば無効な状態であること' do
      column = FactoryBot.build(:column, name: Faker::Lorem.characters(41))
      column.valid?
      expect(column.errors[:name]).to include('は40文字以内で入力してください')
    end

    context 'プロジェクトと組み合わせた場合' do
      let(:column) { FactoryBot.create(:column, name: '営業用タスク') }

      it '同じプロジェクトの中で違う名前であれば有効な状態であること' do
        new_column = FactoryBot.build(:column, project: column.project, name: '人事用タスク')
        expect(new_column).to be_valid
      end

      it '違うプロジェクトの中で同じ名前であれば有効な状態であること' do
        other_project = FactoryBot.create(:project)
        new_column = FactoryBot.build(:column, project: other_project, name: column.name)
        expect(new_column).to be_valid
      end

      it '同じプロジェクトの中で同じ名前であれば無効な状態であること' do
        new_column = FactoryBot.build(:column, project: column.project, name: column.name)
        new_column.valid?
        expect(new_column.errors[:name]).to include('はすでに存在します')
      end
    end
  end
end
