require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'name' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:user)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      user = FactoryBot.build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end
  end
end
