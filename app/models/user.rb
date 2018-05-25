class User < ApplicationRecord
  mount_uploader :image, MypageImageUploader

  has_many :projects, dependent: :destroy
  has_many :assigned_cards, class_name: 'Card',
                            foreign_key: :assignee_id,
                            inverse_of: :assignee,
                            dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :member_projects, through: :memberships, source: :project

  attr_accessor :message

  validates :name, presence: true

  def self.find_or_create_from_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    name = auth[:info][:name]
    image_url = auth[:info][:image]

    find_or_create_by(provider: provider, uid: uid) do |user|
      user.name = name
      user.remote_image_url = image_url
    end
  end

  scope :search, ->(keyword) do
    where('name LIKE ?', "%#{sanitize_sql_like(keyword)}%")
  end

  def notifications_count
    Membership.where(user: self, join: false).count
  end

  after_find do
    @message = 'ログインしました'
  end

  after_create do
    @message = 'アカウント登録しました'
  end

  def destroy
    # ホストが退会するプロジェクトに参加者がいる場合は、ホストを交代する
    target_projects = projects.having_participants
    if target_projects.present?
      manages_accounts_in(target_projects)
    end

    super
  end

  private

  def manages_accounts_in(projects)
    projects.each do |project|
      project.change_host
      project.logs.create(content: "ホストの#{name}さんが退会しました。最古メンバーの#{project.user.name}さんがホストになりました。")
    end
  end
end
