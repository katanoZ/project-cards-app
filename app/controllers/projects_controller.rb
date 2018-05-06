class ProjectsController < ApplicationController
  include ProjectsPagingModules

  def index
    if request.path == myprojects_path
      set_myprojects
    else
      set_projects
    end
  end
end
