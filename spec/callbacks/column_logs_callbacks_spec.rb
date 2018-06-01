require 'rails_helper'

RSpec.describe ColumnLogsCallbacks do
  describe 'after_create' do
    it 'カラム作成後に対応するログが1件出力されること' do
      expect { FactoryBot.create(:column) }.to change(Log.where('content LIKE(?)', '%カラムを作成しました%'), :count).by(1)
    end
  end

  describe 'after_update' do
    before do
      @column = FactoryBot.create(:column, name: '営業用タスク')
    end

    context '名前が変更された場合' do
      it 'カラム更新後に対応するログが1件出力されること' do
        expect { @column.update(name: '開発用タスク') }.to change(Log.where('content LIKE(?)', '%カラムの名前を%'), :count).by(1)
      end
    end

    context '名前が変更されなかった場合' do
      it 'カラム更新後に対応するログが出力されないこと' do
        expect { @column.update(name: '営業用タスク') }.to change(Log.where('content LIKE(?)', '%カラムの名前を%'), :count).by(0)
      end
    end
  end

  describe 'after_destroy' do
    before do
      @column = FactoryBot.create(:column)
    end

    context '作業者がいる場合' do
      it 'カラム削除後に対応するログが1件出力されること' do
        expect { @column.destroy }.to change(Log.where('content LIKE(?)', '%カラムを削除しました%'), :count).by(1)
      end
    end

    context '作業者がいない場合' do
      it 'カラム削除後に対応するログが出力されないこと' do
        @column.operator = nil
        expect { @column.destroy }.to change(Log.where('content LIKE(?)', '%カラムを削除しました%'), :count).by(0)
      end
    end
  end
end
