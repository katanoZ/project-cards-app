require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'name' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:card)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      card = FactoryBot.build(:card, name: nil)
      card.valid?
      expect(card.errors[:name]).to include('を入力してください')
    end

    it '名前が40文字であれば有効な状態であること' do
      card = FactoryBot.build(:card, :name_40)
      expect(card).to be_valid
    end

    it '名前が41文字であれば無効な状態であること' do
      card = FactoryBot.build(:card, :name_41)
      card.valid?
      expect(card.errors[:name]).to include('は40文字以内で入力してください')
    end

    context 'プロジェクトと組み合わせた場合' do
      before do
        @project = FactoryBot.create(:project)
        @card1 = FactoryBot.create(:card, project: @project, name: '資料作成')
      end

      it '同じプロジェクトの中で違う名前であれば有効な状態であること' do
        card2 = FactoryBot.build(:card, project: @project, name: 'テストケース作成')
        expect(card2).to be_valid
      end

      it '同じプロジェクトの中で同じ名前であれば無効な状態であること' do
        card2 = FactoryBot.build(:card, project: @project, name: '資料作成')
        card2.valid?
        expect(card2.errors[:name]).to include('はすでに存在します')
      end

      it '違うプロジェクトの中で同じ名前であれば有効な状態であること' do
        other_project = FactoryBot.create(:project)
        card2 = FactoryBot.build(:card, project: other_project, name: '資料作成')
        expect(card2).to be_valid
      end
    end
  end

  describe 'due_date' do
    it '今日の日付が入っていれば有効な状態であること' do
      card = FactoryBot.build(:card, due_date: Date.today)
      expect(card).to be_valid
    end

    it '日付が入っていなくても有効な状態であること' do
      card = FactoryBot.build(:card, due_date: nil)
      expect(card).to be_valid
    end

    it '昨日の日付が入っていれば無効な状態であること' do
      card = FactoryBot.build(:card, due_date: Date.yesterday)
      card.valid?
      expect(card.errors[:due_date]).to include('は今日から1年後までの範囲で入力してください')
    end

    it '1年後の日付が入っていれば有効な状態であること' do
      card = FactoryBot.build(:card, due_date: Date.today.next_year)
      expect(card).to be_valid
    end

    it '1年後の翌日の日付が入っていれば無効な状態であること' do
      card = FactoryBot.build(:card, due_date: Date.today.next_year + 1)
      card.valid?
      expect(card.errors[:due_date]).to include('は今日から1年後までの範囲で入力してください')
    end
  end

  describe 'self.create_due_date_notification_logs!' do
    context 'カードの種類' do
      it '今日が期限のカードがある場合、ログの種類と数が正しいこと' do
        FactoryBot.create_list(:card, 2, due_date: Date.today)
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%本日が%'), :count).by(2)
      end

      it '昨日が期限のカードがある場合、ログの種類と数が正しいこと' do
        cards = FactoryBot.build_list(:card, 3, due_date: Date.yesterday)
        cards.map { |c| c.save(validate: false) }
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%1日過ぎました%'), :count).by(3)
      end

      it '10日前が期限のカードがある場合、ログの種類と数が正しいこと' do
        cards = FactoryBot.build_list(:card, 4, due_date: Date.today - 10)
        cards.map { |c| c.save(validate: false) }
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%10日過ぎました%'), :count).by(4)
      end

      it '明日が期限のカードがある場合、締切期限のログが作成されないこと' do
        FactoryBot.create_list(:card, 5, due_date: Date.tomorrow)
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%締切期限%'), :count).by(0)
      end

      it '10日後が期限のカードがある場合、締切期限のログが作成されないこと' do
        FactoryBot.create_list(:card, 6, due_date: Date.today + 10)
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%締切期限%'), :count).by(0)
      end

      it '締切期限のないカードがある場合、締切期限のログが作成されないこと' do
        FactoryBot.create_list(:card, 7, due_date: nil)
        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%締切期限%'), :count).by(0)
      end
    end

    context 'カードの組み合わせ' do
      it 'カードの組み合わせの中に対象のカードが9件ある場合、ログが9件作成されること' do
        # 対象
        FactoryBot.create_list(:card, 2, due_date: Date.today)
        cards1 = FactoryBot.build_list(:card, 3, due_date: Date.yesterday)
        cards1.map { |c| c.save(validate: false) }
        cards2 = FactoryBot.build_list(:card, 4, due_date: Date.today - 10)
        cards2.map { |c| c.save(validate: false) }

        # 対象外
        FactoryBot.create_list(:card, 5, due_date: Date.tomorrow)
        FactoryBot.create_list(:card, 6, due_date: Date.today + 10)
        FactoryBot.create_list(:card, 7, due_date: nil)

        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%締切期限%'), :count).by(9)
      end

      it 'カードの組み合わせの中に対象のカードがない場合、ログが作成されないこと' do
        FactoryBot.create_list(:card, 5, due_date: Date.tomorrow)
        FactoryBot.create_list(:card, 6, due_date: Date.today + 10)
        FactoryBot.create_list(:card, 7, due_date: nil)

        expect { Card.create_due_date_notification_logs! }.to change(Log.where('content LIKE(?)', '%締切期限%'), :count).by(0)
      end
    end
  end
end
