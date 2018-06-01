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

  describe 'self.get_myprojects' do
    context 'pageがある場合' do
      before do
        @user = FactoryBot.create(:user)
      end

      it '2ページめで次のページのデータがある場合、9件のプロジェクトが返されること' do
        FactoryBot.create_list(:project, 20, user: @user)
        projects = Project.get_myprojects(@user, 2)
        expect(projects.count).to eq(9)
      end

      it '2ページめで次のページのデータがない場合、ページに表示できる件数のプロジェクトが返されること' do
        FactoryBot.create_list(:project, 11, user: @user)
        projects = Project.get_myprojects(@user, 2)
        expect(projects.count).to eq(3)
      end

      it '2ページめ先頭のプロジェクトが9番目のプロジェクトであること' do
        FactoryBot.create_list(:project, 9, user: @user)
        projects = Project.get_myprojects(@user, 2)
        expect(projects.first).to eq(@user.projects.order(id: :desc).last)
      end
    end

    context 'pageがない場合' do
      context '対象プロジェクトがある場合' do
        before do
          @user = FactoryBot.create(:user)
        end

        it '1ページめで次のページのデータがある場合、8件のプロジェクトが返されること' do
          FactoryBot.create_list(:project, 20, user: @user)
          projects = Project.get_myprojects(@user, nil)
          expect(projects.count).to eq(8)
        end

        it '1ページめで次のページのデータがない場合、ページに表示できる件数のプロジェクトが返されること' do
          FactoryBot.create_list(:project, 4, user: @user)
          projects = Project.get_myprojects(@user, nil)
          expect(projects.count).to eq(4)
        end

        it '1ページめ先頭のプロジェクトが1番目のプロジェクトであること' do
          FactoryBot.create_list(:project, 20, user: @user)
          projects = Project.get_myprojects(@user, nil)
          expect(projects.first).to eq(@user.projects.order(id: :desc).first)
        end
      end

      context '対象プロジェクトがない場合' do
        it '1ページめにプロジェクトが何も返されないこと' do
          user = FactoryBot.create(:user)
          FactoryBot.create_list(:project, 5)

          projects = Project.get_myprojects(user, nil)
          expect(projects.count).to eq(0)
        end
      end
    end
  end

  describe 'self.get_projects' do
    context 'pageがある場合' do
      it '2ページめで次のページのデータがある場合、9件のプロジェクトが返されること' do
        FactoryBot.create_list(:project, 20)
        projects = Project.get_projects(2)
        expect(projects.count).to eq(9)
      end

      it '2ページめで次のページのデータがない場合、ページに表示できる件数のプロジェクトが返されること' do
        FactoryBot.create_list(:project, 11)
        projects = Project.get_projects(2)
        expect(projects.count).to eq(3)
      end

      it '2ページめ先頭のプロジェクトが9番目のプロジェクトであること' do
        FactoryBot.create_list(:project, 9)
        projects = Project.get_projects(2)
        expect(projects.first).to eq(Project.order(id: :desc).last)
      end
    end

    context 'pageがない場合' do
      context '対象プロジェクトがある場合' do
        it '1ページめで次のページのデータがある場合、8件のプロジェクトが返されること' do
          FactoryBot.create_list(:project, 20)
          projects = Project.get_projects(nil)
          expect(projects.count).to eq(8)
        end

        it '1ページめで次のページのデータがない場合、ページに表示できる件数のプロジェクトが返されること' do
          FactoryBot.create_list(:project, 4)
          projects = Project.get_projects(nil)
          expect(projects.count).to eq(4)
        end

        it '1ページめ先頭のプロジェクトが1番目のプロジェクトであること' do
          FactoryBot.create_list(:project, 20)
          projects = Project.get_projects(nil)
          expect(projects.first).to eq(Project.order(id: :desc).first)
        end
      end

      context '対象プロジェクトがない場合' do
        it '1ページめにプロジェクトが何も返されないこと' do
          projects = Project.get_projects(nil)
          expect(projects.count).to eq(0)
        end
      end
    end
  end

  describe 'having_participants' do
    context 'プロジェクトの種類ごと' do
      it '複数のプロジェクトに参加メンバーがいる場合に、返される件数が対象のプロジェクトの件数であること' do
        FactoryBot.create_list(:membership, 4, join: true)
        expect(Project.having_participants.count).to eq(4)
      end

      it '1つのプロジェクトに参加メンバーが複数いる場合に、返される件数が1件であること' do
        project = FactoryBot.create(:project)
        FactoryBot.create_list(:membership, 5, project: project, join: true)
        expect(Project.having_participants.count).to eq(1)
      end

      it '招待されているメンバーしかいない場合に、返される件数が0であること' do
        FactoryBot.create(:project, :with_5_invite_members)
        expect(Project.having_participants.count).to eq(0)
      end

      it 'メンバーがいない場合に、返される件数が0であること' do
        FactoryBot.create(:project)
        expect(Project.having_participants.count).to eq(0)
      end
    end

    context 'プロジェクトの組み合わせ' do
      before do
        # 対象外
        FactoryBot.create(:project, :with_5_invite_members)
        FactoryBot.create(:project)
      end

      it 'プロジェクトの組み合わせの中に対象プロジェクトが4件ある場合、4件のプロジェクトを返すこと' do
        # 対象
        FactoryBot.create_list(:membership, 2, join: true)
        project = FactoryBot.create(:project)
        FactoryBot.create_list(:membership, 3, project: project, join: true) # 1件の扱い
        FactoryBot.create(:project, :with_5_join_members_and_2_invite_members) # 1件の扱い

        expect(Project.having_participants.count).to eq(4)
      end

      it 'プロジェクトの組み合わせの中に対象プロジェクトがない場合、プロジェクトを返さないこと' do
        expect(Project.having_participants.count).to eq(0)
      end
    end
  end

  describe 'accessible' do
    context 'プロジェクトの種類ごと' do
      before do
        @user = FactoryBot.create(:user)
      end

      it 'ホストのいるプロジェクトが複数ある場合に返される件数が、引数のユーザがホストであるプロジェクトの件数であること' do
        FactoryBot.create_list(:project, 3, user: @user)
        FactoryBot.create_list(:project, 4)

        projects = Project.accessible(@user)
        expect(projects.count).to eq 3
      end

      it 'ユーザが参加しているプロジェクトが複数ある場合に返される件数が、引数のユーザが参加しているプロジェクトの件数であること' do
        FactoryBot.create_list(:membership, 4, user: @user, join: true)
        FactoryBot.create_list(:membership, 5, join: true)

        projects = Project.accessible(@user)
        expect(projects.count).to eq 4
      end

      it '同じプロジェクトに引数のユーザを含む参加者が複数人いても、1プロジェクトを返すこと' do
        project = FactoryBot.create(:project)
        FactoryBot.create_list(:membership, 6, project: project, join: true)
        FactoryBot.create(:membership, project: project, user: @user, join: true)

        projects = Project.accessible(@user)
        expect(projects.count).to eq 1
      end

      it '引数のユーザが招待されているプロジェクトが複数あっても、プロジェクトを返さないこと' do
        FactoryBot.create_list(:membership, 7, user: @user, join: false)

        projects = Project.accessible(@user)
        expect(projects.count).to eq 0
      end
    end

    context 'プロジェクトの組み合わせ' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project)

        # 対象外
        FactoryBot.create_list(:project, 4)
        FactoryBot.create_list(:membership, 6, join: true)
        FactoryBot.create_list(:membership, 7, project: @project, join: true)
        FactoryBot.create_list(:membership, 8, user: @user, join: false)
      end

      it 'プロジェクトの組み合わせの中に対象のプロジェクトが9件ある場合、9件のプロジェクトを返すこと' do
        # 対象
        FactoryBot.create_list(:project, 3, user: @user)
        FactoryBot.create_list(:membership, 5, user: @user, join: true)
        FactoryBot.create(:membership, project: @project, user: @user, join: true)

        projects = Project.accessible(@user)
        expect(projects.count).to eq 9
      end

      it 'プロジェクトの組み合わせの中に対象のプロジェクトがない場合、プロジェクトを返さないこと' do
        projects = Project.accessible(@user)
        expect(projects.count).to eq 0
      end
    end
  end

  describe 'accessible?' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'ユーザがアクセス可能なプロジェクトが存在する場合、trueを返すこと' do
      project = FactoryBot.create(:project, user: @user)
      expect(project.accessible?(@user)).to eq(true)
    end

    it 'ユーザがアクセス可能なプロジェクトが存在しない場合、falseを返すこと' do
      project = FactoryBot.create(:project)
      expect(project.accessible?(@user)).to eq(false)
    end
  end

  describe 'host_user?' do
    before do
      @project = FactoryBot.create(:project)
    end

    it '引数のユーザがプロジェクトのホストユーザであればtrueを返すこと' do
      expect(@project.host_user?(@project.user)).to eq true
    end

    it '引数のユーザがプロジェクトのホストユーザでなければfalseを返すこと' do
      user = FactoryBot.create(:user)
      expect(@project.host_user?(user)).to eq false
    end
  end

  describe 'member_user?' do
    before do
      @project = FactoryBot.create(:project, :with_5_join_members_and_2_invite_members)
    end

    it '引数のユーザがプロジェクトの招待メンバーであればtrueを返すこと' do
      user = @project.memberships.where(join: false).sample.user
      expect(@project.member_user?(user)).to eq true
    end

    it '引数のユーザがプロジェクトの参加メンバーであればtrueを返すこと' do
      user = @project.memberships.where(join: true).sample.user
      expect(@project.member_user?(user)).to eq true
    end

    it '引数のユーザがプロジェクトのメンバーでなければfalseを返すこと' do
      user = FactoryBot.create(:user)
      expect(@project.member_user?(user)).to eq false
    end
  end

  describe 'invite!' do
    before do
      @project = FactoryBot.create(:project)
      @user = FactoryBot.create(:user)
    end

    it '実行するとプロジェクトの招待メンバーが1人増えること' do
      expect { @project.invite!(@user) }.to change(@project.memberships.where(join: false), :count).by(1)
    end

    it '実行するとユーザがプロジェクトに招待されていること' do
      @project.invite!(@user)
      membership = @project.memberships.find_by(user: @user)
      expect(membership.join).to eq false
    end
  end

  describe 'change_host' do
    context 'プロジェクトの参加メンバーが1人の場合' do
      before do
        @project = FactoryBot.create(:project, :with_1_join_member)
      end

      it '実行後に、実行前のメンバーがプロジェクトのホストになること' do
        old_member = @project.memberships.find_by(join: true).user
        @project.change_host
        expect(@project.user).to eq old_member
      end

      it '実行後に、参加メンバーが存在しないこと' do
        @project.change_host
        expect(@project.members.count).to eq 0
      end
    end

    context 'プロジェクトの参加メンバーと招待メンバーが複数人の場合' do
      before do
        @project = FactoryBot.create(:project, :with_5_join_members_and_2_invite_members)
        old_memberships = @project.memberships.where(join: true)
        @oldest_member = old_memberships.order(created_at: :asc).first.user
      end

      it '実行後に、実行前の最古参加メンバーがプロジェクトのホストとなること' do
        @project.change_host
        expect(@project.user).to eq @oldest_member
      end

      it '実行後に、実行前より参加メンバーが1人減っていること' do
        expect { @project.change_host }.to change(@project.memberships.where(join: true), :count).by(-1)
      end

      it '実行後に、実行前の最古参加メンバーがメンバー内に存在しないこと' do
        @project.change_host
        expect(@project.members.exists?(id: @oldest_member.id)).to eq false
      end
    end
  end
end
