require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'nameのバリデーション' do
    it '名前があれば有効な状態であること' do
      expect(FactoryBot.build(:user)).to be_valid
    end

    it '名前がなければ無効な状態であること' do
      user = FactoryBot.build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end
  end

  describe '.find_or_create_from_auth' do
    before do
      @auth = Faker::Omniauth.facebook
      @provider = @auth[:provider]
      @uid = @auth[:uid]
    end

    it '該当のユーザがいない場合は作成すること' do
      FactoryBot.create_list(:user, 4, provider: @provider)
      expect { User.find_or_create_from_auth(@auth) }.to change(User, :count).by(1)
    end

    it 'ユーザがいる場合は作成しないこと' do
      FactoryBot.create(:user, provider: @provider, uid: @uid)
      expect { User.find_or_create_from_auth(@auth) }.to change(User, :count).by(0)
    end
  end

  describe ':search' do
    context '名前の種類' do
      it 'キーワードが先頭に含まれている場合、検索結果にユーザが含まれること' do
        user = FactoryBot.create(:user, name: '検索あいうえお')
        expect(User.search('検索')).to include(user)
      end

      it 'キーワードが途中に含まれている場合、検索結果にユーザが含まれること' do
        user = FactoryBot.create(:user, name: 'あいう検索えお')
        expect(User.search('検索')).to include(user)
      end

      it 'キーワードが最後に含まれている場合、検索結果にユーザが含まれること' do
        user = FactoryBot.create(:user, name: 'あいうえお検索')
        expect(User.search('検索')).to include(user)
      end

      it 'キーワードが含まれていない場合、検索結果にユーザが含まれないこと' do
        user = FactoryBot.create(:user, name: 'あいうえお')
        expect(User.search('検索')).to_not include(user)
      end
    end

    context '名前の件数' do
      before do
        @user1 = FactoryBot.create(:user, name: '検索あいうえお')
        @user2 = FactoryBot.create(:user, name: 'あいうえ検索お')
        @user3 = FactoryBot.create(:user, name: 'かきくけこ')
        @user4 = FactoryBot.create(:user, name: 'さしすせそ')
      end
      it 'キーワードが含まれる名前と含まれない名前がある場合、含まれる名前を返すこと' do
        expect(User.search('検索')).to include(@user1, @user2)
        expect(User.search('検索')).to_not include(@user3, @user4)
      end

      it '検索結果が見つからない時は、空のコレクションを返すこと' do
        expect(User.search('名前')).to be_empty
      end
    end
  end

  describe '#notifications_count' do
    it 'ユーザに招待も参加もない場合は0を返す' do
      user = FactoryBot.create(:user)
      expect(user.notifications_count).to be 0
    end

    it 'ユーザに招待だけがある場合は招待数を返す' do
      user = FactoryBot.create(:user, :with_5_invitations)
      expect(user.notifications_count).to be 5
    end

    it 'ユーザに招待と参加がある場合は招待数を返す' do
      user = FactoryBot.create(:user, :with_4_invitations_and_3_participations)
      expect(user.notifications_count).to be 4
    end

    it 'ユーザに参加だけがある場合は0を返す' do
      user = FactoryBot.create(:user, :with_6_participations)
      expect(user.notifications_count).to be 0
    end
  end

  describe 'before_destroy' do
    let(:user) { FactoryBot.create(:user, :with_6_host_projects) }
    let(:project) { user.projects.first }

    describe '#handles_projects' do
      it 'ユーザがホストをしているプロジェクトの中に参加者がいる場合は、manages_accounts_inメソッドを実行すること' do
        FactoryBot.create(:membership, project: project, join: true)
        expect(user).to receive(:manages_accounts_in)
        user.destroy
      end

      it 'ユーザがホストをしているプロジェクトに参加者がいない場合は、anages_accounts_inメソッドを実行しないこと' do
        FactoryBot.create(:membership, project: project, join: false)
        expect(user).not_to receive(:manages_accounts_in)
        user.destroy
      end
    end

    describe '#manages_accounts_in' do
      before do
        FactoryBot.create(:membership, project: project, join: true)
      end

      it 'ユーザがホストをしているプロジェクトの中に処理対象が1件ある場合は、該当プロジェクトのログが1件増えること' do
        FactoryBot.create(:membership, project: project, join: true)
        expect { user.destroy }.to change(Log.where(project: project), :count).by(1)
      end

      it 'ユーザがホストをしているプロジェクトの中に処理対象が複数件ある場合は、該当プロジェクトのログが複数件増えること' do
        project2 = user.projects.last
        FactoryBot.create(:membership, project: project2, join: true)
        expect { user.destroy }.to change(Log.where(project: [project, project2]), :count).by(2)
      end
    end
  end
end
