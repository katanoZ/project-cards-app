class ProjectsController < ApplicationController
  def index
    if request.path == myprojects_path
      @projects = current_user.projects.order(id: :asc).page(params[:page])
    else
      @projects = Project.order(id: :asc).page(params[:page])
    end
  end
end
