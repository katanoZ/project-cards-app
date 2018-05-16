class User < ApplicationRecord
  mount_uploader :image, MypageImageUploader

  has_many :projects, dependent: :destroy
  has_many :assigned_cards, class_name: 'Card',
                            foreign_key: :assignee_id,
                            inverse_of: :assignee,
                            dependent: :destroy

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

  after_find do
    @message = 'ログインしました'
  end

  after_create do
    @message = 'アカウント登録しました'
  end
end
