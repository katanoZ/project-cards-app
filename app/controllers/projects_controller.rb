class ProjectsController < ApplicationController
  def index
    @projects = Project.order(id: :asc).page(params[:page])
  end
end
