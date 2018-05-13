class Project < ApplicationRecord
  belongs_to :user
  has_many :columns, -> { order(position: :asc) }, dependent: :destroy

  COUNT_FOR_FIRST_PAGE = 8
  COUNT_FOR_OTHER_PAGE = 9

  validates :name, presence: true, uniqueness: true, length: { maximum: 140 }
  validates :summary, length: { maximum: 300 }

  def self.get_myprojects(user, page)
    if page
      user.projects.order(id: :desc).page(page).per(COUNT_FOR_OTHER_PAGE)
          .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
    else
      user.projects.order(id: :desc).page(page).per(COUNT_FOR_FIRST_PAGE)
    end
  end

  def self.get_projects(page)
    if page
      order(id: :desc).page(page).per(COUNT_FOR_OTHER_PAGE)
                      .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
    else
      order(id: :desc).page(page).per(COUNT_FOR_FIRST_PAGE)
    end
  end

  scope :accessible, ->(user) do
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクト を返す
    user.projects
  end

  def accessible?(user)
    #TODO: userが作ったプロジェクト or userがメンバーに入っているプロジェクトかどうか？を返す
    user == self.user
  end
end
