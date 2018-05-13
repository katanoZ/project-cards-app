class ColumnsController < ApplicationController
  before_action :set_project, only: %i[new create]

  def new
    @column = @project.columns.build
  end

  def create
    @column = @project.columns.build(column_params)

    if @column.save
      redirect_to project_path(@project), notice: 'カラムを作成しました'
    else
      render :new
    end
  end

  private

  def column_params
    params.require(:column).permit(:name)
  end

  def set_project
    @project = Project.accessible(current_user).find(params[:project_id])
  end
end
