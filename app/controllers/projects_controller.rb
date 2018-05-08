class ProjectsController < ApplicationController
  include ProjectsPagingModules

  def index
    if request.path == myprojects_path
      set_myprojects
    else
      set_projects
    end
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)

    if @project.save
      redirect_to myprojects_path, notice: 'プロジェクトを作成しました'
    else
      render :new
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :summary)
  end
end
