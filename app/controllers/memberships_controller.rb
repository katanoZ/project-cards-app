class MembershipsController < ApplicationController
  before_action :set_project, only: %i[create]

  def index
    @memberships = Membership.where(user: current_user, join: false)
                             .includes(project: :user)
                             .order(created_at: :desc)
                             .page(params[:page])
  end

  def create
    user = User.find(params[:user_id])
    @project.invite!(user)
    redirect_to project_path(@project), notice: "#{user.name}さんをプロジェクトに招待しました"
  end

  def update
    membership = current_user.memberships.find(params[:id])
    membership.join!
    redirect_to project_path(membership.project), notice: 'プロジェクトに参加しました'
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end
end
