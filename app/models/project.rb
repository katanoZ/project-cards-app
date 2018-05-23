class Project < ApplicationRecord
  belongs_to :user
  has_many :columns, -> { order(position: :asc) }, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user

  COUNT_FOR_FIRST_PAGE = 8
  COUNT_FOR_OTHER_PAGE = 9

  validates :name, presence: true, uniqueness: true, length: { maximum: 140 }
  validates :summary, length: { maximum: 300 }

  def self.get_myprojects(user, page)
    if page
      accessible(user).order(id: :desc).page(page).per(COUNT_FOR_OTHER_PAGE)
                      .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
    else
      accessible(user).order(id: :desc).page(page).per(COUNT_FOR_FIRST_PAGE)
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
    relation = Project.left_joins(:memberships)
    relation.merge(Membership.where(user: user, join: true))
            .or(relation.where(user: user))
  end

  def accessible?(user)
    Project.accessible(user).exists?(id)
  end

  def host_user?(user)
    user == self.user
  end

  def member_user?(user)
    members.exists?(id: user.id)
  end

  def invite!(user)
    Membership.create!(project: self, user: user)
  end
end
