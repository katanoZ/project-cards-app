class ProjectsController < ApplicationController
  include ProjectsPagingModules

  before_action :set_project, only: %i[edit update destroy]

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

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to myprojects_path, notice: 'プロジェクトを更新しました'
    else
      render :edit
    end
  end

  def destroy
    if @project.destroy
      redirect_to myprojects_path, notice: 'プロジェクトを削除しました'
    else
      flash.now[:alert] = 'プロジェクトの削除に失敗しました。'
      render :edit
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :summary)
  end

  def set_project
    @project = current_user.projects.find(params[:id])
  end
end
