require 'rails_helper'

RSpec.describe CardLogsCallbacks do
  describe 'after_create' do
    it 'カード作成後に対応するログが1件出力されること' do
      expect { FactoryBot.create(:card) }.to change(Log.where('content LIKE(?)', '%カードを作成しました%'), :count).by(1)
    end
  end

  describe 'after_save' do
    describe 'due_date_log' do
      context 'カード作成時' do
        it 'カード作成時に対応するログが1件出力されること' do
          expect { FactoryBot.create(:card) }.to change(Log.where('content LIKE(?)', '%カードの期限を%'), :count).by(1)
        end

        it 'カードを作成時に締切日を入力しないと、対応するログが出力されないこと' do
          expect { FactoryBot.create(:card, due_date: nil) }.to change(Log.where('content LIKE(?)', '%カードの期限を%'), :count).by(0)
        end
      end

      context 'カード更新時' do
        before do
          @card = FactoryBot.create(:card)
        end

        it 'カード更新時に締切日を変更すると、対応するログが1件出力されること' do
          expect { @card.update(due_date: Date.today + 5) }.to change(Log.where('content LIKE(?)', '%カードの期限を%'), :count).by(1)
        end

        it 'カードを更新時に締切日をなしに変更すると、対応するログが1件出力されること' do
          expect { @card.update(due_date: nil) }.to change(Log.where('content LIKE(?)', '%カードの期限を%'), :count).by(1)
        end

        it 'カード更新時に締切日を変更しないと、対応するログが出力されないこと' do
          expect { @card.update(name: '名前を変更') }.to change(Log.where('content LIKE(?)', '%カードの期限を%'), :count).by(0)
        end
      end
    end

    describe 'assign_log' do
      context 'カード作成時' do
        it 'カード作成時に対応するログが1件出力されること' do
          expect { FactoryBot.create(:card) }.to change(Log.where('content LIKE(?)', '%アサインしました%'), :count).by(1)
        end
      end

      context 'カード更新時' do
        before do
          @card = FactoryBot.create(:card)
        end

        it 'カード更新時に担当者を変えると、対応するログが1件出力されること' do
          user = FactoryBot.create(:user)
          expect { @card.update(assignee: user) }.to change(Log.where('content LIKE(?)', '%アサインしました%'), :count).by(1)
        end

        it 'カード更新時に担当者を変えないと、対応するログが出力されないこと' do
          expect { @card.update(name: '名前を変更') }.to change(Log.where('content LIKE(?)', '%アサインしました%'), :count).by(0)
        end
      end
    end
  end

  describe 'after_update' do
    before do
      @card = FactoryBot.create(:card)
    end

    describe 'name_edit_log' do
      it 'カード更新時に名前を変えると対応するログが1件出力されること' do
        expect { @card.update(name: '名前を変更') }.to change(Log.where('content LIKE(?)', '%カードの名前を%'), :count).by(1)
      end

      it 'カード更新時に名前を変えないと対応するログが出力されないこと' do
        expect { @card.update(due_date: Date.today + 10) }.to change(Log.where('content LIKE(?)', '%カードの名前を%'), :count).by(0)
      end
    end

    describe 'move_log' do
      it 'カードを移動すると対応するログが1件出力されること' do
        another_column = FactoryBot.create(:column, project: @card.project)
        expect { @card.update(column: another_column) }.to change(Log.where('content LIKE(?)', '%カラムに移動しました%'), :count).by(1)
      end
    end
  end

  describe 'after_destroy' do
    before do
      @card = FactoryBot.create(:card)
    end

    context '作業者がいる場合' do
      it 'カードを削除すると対応するログが1件出力されること' do
        expect { @card.destroy }.to change(Log.where('content LIKE(?)', '%カードを削除しました%'), :count).by(1)
      end
    end

    context '作業者がいない場合' do
      it 'カードを削除すると対応するログが1件出力されること' do
        @card.operator = nil
        expect { @card.destroy }.to change(Log.where('content LIKE(?)', '%カードが削除されました%'), :count).by(1)
      end
    end
  end
end
