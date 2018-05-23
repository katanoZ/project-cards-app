class LogsController < ApplicationController
  def index
    @project = Project.accessible(current_user).find(params[:project_id])
    @logs = @project.logs.order(created_at: :desc).page(params[:page])
  end
end
