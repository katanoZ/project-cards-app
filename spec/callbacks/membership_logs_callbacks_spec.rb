require 'rails_helper'

RSpec.describe MembershipLogsCallbacks do
  describe 'after_create' do
    it '招待作成後に対応するログが1件出力されること' do
      expect { FactoryBot.create(:membership) }.to change(Log.where('content LIKE(?)', '%招待しました%'), :count).by(1)
    end
  end

  describe 'after_update' do
    context 'joinをtrueに変更した場合' do
      it 'プロジェクトに参加後に対応するログが1件出力されること' do
        membership = FactoryBot.create(:membership)
        expect { membership.join! }.to change(Log.where('content LIKE(?)', '%参加しました%'), :count).by(1)
      end
    end

    context 'joinをfalseに変更した場合' do
      it '更新後に対応するログが出力されないこと' do
        membership = FactoryBot.create(:membership, join: true)
        expect { membership.update(join: false) }.to change(Log.where('content LIKE(?)', '%参加しました%'), :count).by(0)
      end
    end

    context 'joinがtrueのままで更新した場合' do
      it '更新後に対応するログが出力されないこと' do
        membership = FactoryBot.create(:membership, join: true)
        expect { membership.join! }.to change(Log.where('content LIKE(?)', '%参加しました%'), :count).by(0)
      end
    end
  end

  describe 'after_destroy' do
    context 'メンバーが参加している場合' do
      it 'メンバー削除後に対応するログが1件出力されること' do
        membership = FactoryBot.create(:membership, join: true)
        expect { membership.destroy }.to change(Log.where('content LIKE(?)', '%退会しました%'), :count).by(1)
      end
    end

    context 'メンバーが参加していない場合' do
      it 'メンバー削除後に対応するログが出力されないこと' do
        membership = FactoryBot.create(:membership)
        expect { membership.destroy }.to change(Log.where('content LIKE(?)', '%退会しました%'), :count).by(0)
      end
    end
  end
end
