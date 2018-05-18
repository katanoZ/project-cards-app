class Membership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :project_id, uniqueness: { scope: :user_id }

  before_save :excludes_host_user

  private

  def excludes_host_user
    throw(:abort) if project.host_user?(user)
  end
end
