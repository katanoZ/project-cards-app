class User < ApplicationRecord
  mount_uploader :image, MypageImageUploader

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

  after_find do
    @message = 'ログインしました'
  end

  after_create do
    @message = 'アカウント登録しました'
  end
end
