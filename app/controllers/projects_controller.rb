class ProjectsController < ApplicationController
  def index
    @projects = Project.all.order(id: :asc)
  end
end
