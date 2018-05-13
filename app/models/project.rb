class Project < ApplicationRecord
  belongs_to :user
  has_many :columns, -> { order(position: :asc) }, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 140 }
  validates :summary, length: { maximum: 300 }

  COUNT_FOR_FIRST_PAGE = 8
  COUNT_FOR_OTHER_PAGE = 9

  scope :accessible, ->(user) do
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクト を返す
    user.projects
  end

  def accessible?(user)
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクトかどうか？を返す
    user == self.user
  end

  def self.set_myprojects(user, page)
    if page
      user.projects.order(id: :desc).page(page).per(COUNT_FOR_OTHER_PAGE)
          .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
    else
      user.projects.order(id: :desc).page(page).per(COUNT_FOR_FIRST_PAGE)
    end
  end

  def self.set_projects(page)
    if page
      Project.order(id: :desc).page(page).per(COUNT_FOR_OTHER_PAGE)
             .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
    else
      Project.order(id: :desc).page(page).per(COUNT_FOR_FIRST_PAGE)
    end
  end
end
