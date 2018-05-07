module ApplicationHelper
  def logged_in_projects?
    logged_in? && controller.controller_name == 'projects'
  end
end
