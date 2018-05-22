class Membership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_one :project_user, through: :project, source: :user

  validates :project_id, uniqueness: { scope: :user_id }

  before_save :excludes_host_user
  after_create MembershipLogsCallbacks.new
  after_update MembershipLogsCallbacks.new

  paginates_per 5

  def join!
    raise '既にプロジェクトに参加しています' if join
    update!(join: true)
  end

  private

  def excludes_host_user
    throw(:abort) if project.host_user?(user)
  end
end
