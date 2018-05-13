class Project < ApplicationRecord
  belongs_to :user
  has_many :columns, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 140 }
  validates :summary, length: { maximum: 300 }

  scope :accessible, ->(user) do
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクト を返す
    user.projects
  end

  def accessible?(user)
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクトかどうか？を返す
    user == self.user
  end

  def host_user?(user)
    user == self.user
  end
end
