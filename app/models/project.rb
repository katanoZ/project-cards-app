class Project < ApplicationRecord
  belongs_to :user
  has_many :columns, -> { order(position: :asc) }, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :logs, dependent: :destroy

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

  scope :having_participants, -> do
    joins(:memberships).where(memberships: { join: true }).distinct
  end

  scope :accessible, ->(user) do
    joined_table = Project.left_joins(:memberships)
    joined_table.merge(Membership.where(user: user, join: true))
            .or(joined_table.where(user: user))
            .distinct
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

  def change_host
    oldest_membersip = memberships.where(join: true).order(updated_at: :asc).first
    oldest_member = oldest_membersip.user

    oldest_membersip.delete
    update(user: oldest_member)
  end
end
